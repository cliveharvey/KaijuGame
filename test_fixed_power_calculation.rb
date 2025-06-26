#!/usr/bin/env ruby

require_relative 'models/kaiju'
require_relative 'models/squad'
require_relative 'models/soldier'

puts "🧪 TESTING FIXED POWER CALCULATION (No 1.8x Inflation)"
puts "=" * 60

# Create two typical new squads
squad1 = Squad.new("Test Squad Alpha", 5)
squad2 = Squad.new("Test Squad Beta", 5)

squads = [squad1, squad2]
combined_total = squads.sum { |s| s.soldiers.sum(&:total_skill) }
combined_avg = combined_total / squads.sum { |s| s.soldiers.count }

puts "\n📊 SQUAD ANALYSIS:"
puts "Combined Total: #{combined_total}"
puts "Combined Average: #{combined_avg}"
puts "No inflation applied - using actual squad power"

puts "\n🎯 NEW DIFFICULTY RANGES (based on actual power):"
puts "Easy (70%): #{(combined_avg * 0.15).round} to #{(combined_avg * 0.3).round}"
puts "Moderate (25%): #{(combined_avg * 0.3).round} to #{(combined_avg * 0.45).round}"
puts "Hard (5%): #{(combined_avg * 0.45).round} to #{(combined_avg * 0.6).round}"

puts "\n🦖 GENERATING 20 KAIJU:"
puts "-" * 60

difficulties = []
easy_count = 0
moderate_count = 0
hard_count = 0

20.times do |i|
  kaiju = Kaiju.new(squads)
  difficulties << kaiju.difficulty

  if kaiju.difficulty <= (combined_avg * 0.3).round
    easy_count += 1
    level = "EASY"
  elsif kaiju.difficulty <= (combined_avg * 0.45).round
    moderate_count += 1
    level = "MODERATE"
  else
    hard_count += 1
    level = "HARD"
  end

  puts "#{i+1}. #{kaiju.name_english} - Difficulty: #{kaiju.difficulty} (#{level})"
end

puts "\n📊 RESULTS:"
puts "Range: #{difficulties.min}-#{difficulties.max}"
puts "Average: #{(difficulties.sum / difficulties.length.to_f).round(1)}"
puts "Easy: #{easy_count}/20 (#{easy_count * 5}%)"
puts "Moderate: #{moderate_count}/20 (#{moderate_count * 5}%)"
puts "Hard: #{hard_count}/20 (#{hard_count * 5}%)"

puts "\n✅ COMPARISON TO ACTUAL SQUAD POWER:"
worst_soldier = squads.flat_map(&:soldiers).map(&:total_skill).min
avg_soldier = combined_avg
best_soldier = squads.flat_map(&:soldiers).map(&:total_skill).max

puts "Worst soldier: #{worst_soldier}"
puts "Average soldier: #{avg_soldier}"
puts "Best soldier: #{best_soldier}"
puts "Difficulty range: #{difficulties.min}-#{difficulties.max}"
puts "Threat vs worst: #{(difficulties.min.to_f/worst_soldier).round(2)} - #{(difficulties.max.to_f/worst_soldier).round(2)}"
puts "Threat vs average: #{(difficulties.min.to_f/avg_soldier).round(2)} - #{(difficulties.max.to_f/avg_soldier).round(2)}"

puts "\n🔄 COMPARISON TO OLD SYSTEM:"
old_inflated_avg = (combined_total * 1.8) / squads.sum { |s| s.soldiers.count }
puts "Old inflated average: #{old_inflated_avg.round}"
puts "New actual average: #{combined_avg}"
puts "Difference: #{(old_inflated_avg - combined_avg).round} points of artificial inflation"
