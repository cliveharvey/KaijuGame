require 'sinatra'
require 'sinatra/json'
require 'json'
require 'ostruct'
require 'securerandom'
require_relative 'game_state'
require_relative 'models/kaiju'
require_relative 'models/location'
require_relative 'models/squad'
require_relative 'systems/battle_system'

class WebKaijuGame < Sinatra::Base
  # Enable sessions for game state persistence
  # Use environment variable for session secret, generate one if not set
  session_secret = ENV['SESSION_SECRET'] || SecureRandom.hex(32)
  use Rack::Session::Cookie, :key => 'rack.session',
                             :secret => session_secret

  # Serve static files
  set :public_folder, 'public'
  # Initialize game state in session
  before do
    session[:game_state] ||= GameState.new.to_hash
  end

  # Main game page
  get '/' do
    erb :index
  end

  # API endpoints
  get '/api/game_state' do
    json session[:game_state]
  end

  # Start new game
  post '/api/new_game' do
    session[:game_state] = GameState.new.to_hash
    json({ success: true, message: "New game started!" })
  end

  # Get current mission
  get '/api/mission' do
    game_state = GameState.from_hash(session[:game_state])

    if game_state.has_pending_mission?
      json({
        has_mission: true,
        mission: game_state.pending_mission
      })
    else
      # Generate new mission
      squads = game_state.get_squads
      kaiju = Kaiju.new(squads)
      location = Location.new
      game_state.set_pending_mission(kaiju, location)

      # Update session
      session[:game_state] = game_state.to_hash

      json({
        has_mission: true,
        mission: game_state.pending_mission
      })
    end
  end

  # Get available squads for mission
  get '/api/squads' do
    game_state = GameState.from_hash(session[:game_state])
    squads = game_state.get_squads

    # Get current mission for threat assessment
    pending_mission = game_state.pending_mission
    kaiju_data = pending_mission[:kaiju] if pending_mission

    # Create battle text generator for risk assessment
    battle_text = BattleText.new

    squads_data = squads.map.with_index do |squad, index|
      squad_info = {
        id: index,
        name: squad.name,
        soldiers: squad.soldiers.map do |soldier|
          {
            name: soldier.name,
            level: soldier.level,
            offense: soldier.offense,
            defense: soldier.defense,
            grit: soldier.grit,
            leadership: soldier.leadership,
            status: soldier.status,
            total_skill: soldier.total_skill
          }
        end
      }

      # Add casualty risk assessment if there's a pending mission
      if kaiju_data
        temp_kaiju = OpenStruct.new(kaiju_data)
        casualty_risk = battle_text.send(:estimate_casualty_risk, squad, temp_kaiju)

        # Calculate squad strength metrics
        total_offense = squad.soldiers.sum(&:offense)
        total_defense = squad.soldiers.sum(&:defense)
        avg_leadership = squad.soldiers.sum(&:leadership) / squad.soldiers.count
        avg_skill = squad.soldiers.sum(&:total_skill) / squad.soldiers.count

        squad_info[:threat_assessment] = {
          casualty_risk: casualty_risk,
          total_offense: total_offense,
          total_defense: total_defense,
          avg_leadership: avg_leadership,
          avg_skill: avg_skill,
          kaiju_difficulty: kaiju_data[:difficulty]
        }
      end

      squad_info
    end

    json({ squads: squads_data })
  end

  # Accept mission and deploy squad
  post '/api/deploy' do
    request.body.rewind
    data = JSON.parse(request.body.read)
    squad_id = data['squad_id'].to_i

    game_state = GameState.from_hash(session[:game_state])

    # Debug output
    puts "DEBUG: Session game_state: #{session[:game_state]['pending_mission'] ? 'HAS PENDING MISSION' : 'NO PENDING MISSION'}"
    puts "DEBUG: Raw session pending_mission: #{session[:game_state]['pending_mission'].inspect}"
    puts "DEBUG: Game state has_pending_mission?: #{game_state.has_pending_mission?}"
    puts "DEBUG: Game state pending_mission: #{game_state.pending_mission.inspect}"

    unless game_state.has_pending_mission?
      return json({ success: false, message: "No pending mission!" })
    end

    squads = game_state.get_squads
    selected_squad = squads[squad_id]

    unless selected_squad
      return json({ success: false, message: "Invalid squad selection!" })
    end

    # Conduct battle with detailed narrative
    battle_system = BattleSystem.new
    pending_mission = game_state.pending_mission

    # Create temporary kaiju object for battle
    kaiju_data = pending_mission[:kaiju]
    location_data = pending_mission[:location]
    temp_kaiju = OpenStruct.new(kaiju_data)

    # Generate battle narrative
    battle_text = BattleText.new

    # Get battle intro
    battle_intro = battle_text.get_detailed_battle_intro(selected_squad, temp_kaiju)

    # Run the battle
    success = selected_squad.combat(temp_kaiju)
    casualties = selected_squad.soldiers.count { |s| s.status == :kia }

    # Generate individual soldier battle reports
    soldier_reports = []
    selected_squad.soldiers.each do |soldier|
      soldier_report = {
        name: soldier.name,
        status: soldier.status.to_s,
        battle_narrative: battle_text.battle_summary(soldier),
        pre_battle_stats: {
          level: soldier.level,
          offense: soldier.offense,
          defense: soldier.defense,
          grit: soldier.grit,
          leadership: soldier.leadership
        }
      }
      soldier_reports << soldier_report
    end

    # Award experience and handle promotions
    level_ups = {}
    promotion_details = {}

    selected_squad.soldiers.each do |soldier|
      next if soldier.status == :kia

      # Store pre-promotion stats
      old_stats = {
        level: soldier.level,
        offense: soldier.offense,
        defense: soldier.defense,
        grit: soldier.grit,
        leadership: soldier.leadership
      }

      soldier_level_ups = soldier.complete_mission

      if soldier_level_ups.any?
        level_ups[soldier.name] = soldier_level_ups
        promotion_details[soldier.name] = {
          old_stats: old_stats,
          new_stats: {
            level: soldier.level,
            offense: soldier.offense,
            defense: soldier.defense,
            grit: soldier.grit,
            leadership: soldier.leadership
          },
          level_ups: soldier_level_ups
        }
      end

      # Reset status for next mission
      soldier.status = :alive if soldier.status != :kia
      soldier.success = false
    end

    # Generate mission outcome narrative
    mission_outcome = if success
      [
        "🎉 MISSION SUCCESSFUL!",
        "The kaiju has been neutralized and the city is safe!",
        "#{selected_squad.name} has proven their worth in combat.",
        "Civilian casualties were minimized thanks to swift action."
      ]
    else
      [
        "💥 MISSION FAILED",
        "The kaiju proved too powerful for the deployed forces.",
        "#{location_data[:city]} remains under threat.",
        "Emergency evacuation protocols are now in effect."
      ]
    end

        # Count casualties before removing dead soldiers
    casualty_list = selected_squad.soldiers.select { |s| s.status == :kia }.map(&:name)

    # Remove dead soldiers
    selected_squad.soldiers.reject! { |soldier| soldier.status == :kia }

    # Auto-recruit replacements for casualties
    recruitment_details = []
    if casualties > 0
      casualties.times do
        recruit = game_state.create_recruit
        recruit.background = game_state.extract_background_from_name(recruit.name)
        recruit_name_with_profession = recruit.name
        recruit.name = game_state.clean_recruit_name(recruit.name)

        selected_squad.soldiers << recruit
        recruitment_details << {
          name: recruit.name,
          background: recruit.background,
          stats: {
            level: recruit.level,
            offense: recruit.offense,
            defense: recruit.defense,
            grit: recruit.grit,
            leadership: recruit.leadership
          }
        }
      end
      game_state.instance_variable_set(:@recruits_added, game_state.instance_variable_get(:@recruits_added) + casualties)
    end

    # Record mission results
    game_state.record_mission_result(success, success, casualties)
    game_state.clear_pending_mission

    # Update session with modified game state
    session[:game_state] = game_state.to_hash

    json({
      success: true,
      mission_success: success,
      casualties: casualties,
      casualty_list: casualty_list,
      level_ups: level_ups,
      promotion_details: promotion_details,
      recruitment_details: recruitment_details,
      battle_intro: battle_intro,
      soldier_reports: soldier_reports,
      mission_outcome: mission_outcome,
      kaiju: {
        name: kaiju_data[:name_english],
        designation: kaiju_data[:name_monster],
        location: location_data[:city],
        difficulty: kaiju_data[:difficulty]
      },
      squad: {
        name: selected_squad.name,
        soldiers: selected_squad.soldiers.map do |soldier|
          {
            name: soldier.name,
            level: soldier.level,
            offense: soldier.offense,
            defense: soldier.defense,
            grit: soldier.grit,
            leadership: soldier.leadership,
            status: soldier.status,
            total_skill: soldier.total_skill
          }
        end
      }
    })
  end

  # Reject mission
  post '/api/reject_mission' do
    game_state = GameState.from_hash(session[:game_state])

    if game_state.has_pending_mission?
      # Record city destruction
      game_state.record_city_destruction
      game_state.clear_pending_mission

      session[:game_state] = game_state.to_hash

      json({
        success: true,
        message: "Mission rejected. The city has been destroyed...",
        cities_destroyed: game_state.get_cities_destroyed
      })
    else
      json({ success: false, message: "No pending mission to reject!" })
    end
  end

  # Get game statistics
  get '/api/stats' do
    game_state = GameState.from_hash(session[:game_state])

    json({
      missions_completed: game_state.get_missions_completed,
      cities_destroyed: game_state.get_cities_destroyed,
      squads: game_state.get_squads.count
    })
  end

  run! if app_file == $0
end
