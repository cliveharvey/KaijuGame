class KaijuGame {
    constructor() {
        this.currentMission = null;
        this.squads = [];
        this.selectedSquad = null;
        this.gameStats = { missions_completed: 0, cities_destroyed: 0 };
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.showPanel('loading');
    }

    setupEventListeners() {
        // Game flow buttons
        document.getElementById('start-game-btn').addEventListener('click', () => {
            this.startGame();
        });

        document.getElementById('accept-mission-btn').addEventListener('click', () => {
            this.acceptMission();
        });

        document.getElementById('reject-mission-btn').addEventListener('click', () => {
            this.rejectMission();
        });

        document.getElementById('new-mission-btn').addEventListener('click', () => {
            this.generateNewMission();
        });

        document.getElementById('deploy-squad-btn').addEventListener('click', () => {
            this.deploySquad();
        });

        document.getElementById('back-to-mission-btn').addEventListener('click', () => {
            this.showPanel('mission');
        });

        document.getElementById('continue-operations-btn').addEventListener('click', () => {
            this.continueOperations();
        });

        // Navigation buttons
        document.getElementById('nav-mission-btn').addEventListener('click', () => {
            this.switchToPanel('mission');
        });

        document.getElementById('nav-squads-btn').addEventListener('click', () => {
            this.switchToPanel('squads');
        });

        // Squad management event listeners
        document.getElementById('close-soldier-details').addEventListener('click', () => {
            this.closeSoldierDetails();
        });
    }

    // Switch between main panels
    async switchToPanel(panelType) {
        if (panelType === 'mission') {
            // Update nav buttons
            document.getElementById('nav-mission-btn').classList.add('active');
            document.getElementById('nav-squads-btn').classList.remove('active');

            // Show mission panel
            await this.startGame();
        } else if (panelType === 'squads') {
            // Update nav buttons
            document.getElementById('nav-mission-btn').classList.remove('active');
            document.getElementById('nav-squads-btn').classList.add('active');

            // Load and show squad management
            await this.loadSquadManagement();
            this.showPanel('squad-management');
        }
    }

    // Load squad management data
    async loadSquadManagement() {
        try {
            const response = await fetch('/api/squad_management', {
                method: 'GET',
                credentials: 'include'
            });

            const data = await response.json();

            if (data.success) {
                this.displaySquadManagement(data.squads);
            } else {
                console.error('Failed to load squad management data');
            }
        } catch (error) {
            console.error('Error loading squad management:', error);
        }
    }

    // Display squad management interface
    displaySquadManagement(squads) {
        const squadList = document.getElementById('squad-list');
        squadList.innerHTML = '';

        squads.forEach(squad => {
            const squadCard = this.createSquadCard(squad);
            squadList.appendChild(squadCard);
        });
    }

    // Create squad card element
    createSquadCard(squad) {
        const card = document.createElement('div');
        card.className = 'squad-card';

        const stats = squad.statistics;
        const hasMissions = stats.missions_completed > 0;

        card.innerHTML = `
            <div class="squad-header">
                <h3 class="squad-name">${squad.name}</h3>
                <div class="squad-soldier-count">👥 ${squad.soldier_count} Soldiers</div>
            </div>

            ${hasMissions ? `
                <div class="squad-stats">
                    <div class="stat-item">
                        <span class="stat-label">🎯 Missions</span>
                        <span class="stat-value">${stats.missions_completed}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">🏆 Victories</span>
                        <span class="stat-value">${stats.victories}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">📈 Success Rate</span>
                        <span class="stat-value">${stats.success_rate}%</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">⚰️ Casualties</span>
                        <span class="stat-value">${stats.total_casualties}</span>
                    </div>
                </div>

                ${stats.toughest_kaiju ? `
                    <div class="toughest-kaiju">
                        <h4>🏆 Toughest Kaiju Defeated</h4>
                        <div class="kaiju-name">${stats.toughest_kaiju.name}</div>
                        <div class="kaiju-details">
                            ${this.capitalizeFirst(stats.toughest_kaiju.size)} ${stats.toughest_kaiju.creature} •
                            Threat Level ${stats.toughest_kaiju.difficulty} •
                            ${stats.toughest_kaiju.location}
                        </div>
                    </div>
                ` : ''}
            ` : `
                <div class="no-missions">
                    <p>🆕 Fresh squad with no combat experience</p>
                    <p>Deploy them on missions to build their reputation!</p>
                </div>
            `}

            <div class="soldiers-preview">
                <h4>👥 Squad Roster</h4>
                <div class="soldier-list">
                    ${squad.soldiers.map(soldier => `
                        <div class="soldier-item" onclick="game.showSoldierDetails('${squad.name}', '${soldier.name}')">
                            <div class="soldier-name">${soldier.name}</div>
                            <div class="soldier-level">Level ${soldier.level}</div>
                            <div class="soldier-skill">Total Skill: ${soldier.total_skill}</div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;

        return card;
    }

    // Show soldier details modal
    async showSoldierDetails(squadName, soldierName) {
        try {
            const response = await fetch('/api/squad_management', {
                method: 'GET',
                credentials: 'include'
            });

            const data = await response.json();

            if (data.success) {
                const squad = data.squads.find(s => s.name === squadName);
                const soldier = squad.soldiers.find(s => s.name === soldierName);

                if (soldier) {
                    this.displaySoldierDetails(soldier);
                    document.getElementById('soldier-details').style.display = 'flex';
                }
            }
        } catch (error) {
            console.error('Error loading soldier details:', error);
        }
    }

    // Display soldier details in modal
    displaySoldierDetails(soldier) {
        const content = document.getElementById('soldier-details-content');
        document.getElementById('soldier-details-title').textContent = `${soldier.name} - Details`;

        content.innerHTML = `
            <div class="soldier-details-card">
                <div class="soldier-details-header">
                    <h2 class="soldier-details-name">${soldier.name}</h2>
                    <span class="level-badge">Level ${soldier.level}</span>
                </div>

                <div class="soldier-info-grid">
                    <div class="info-section">
                        <h4>⚔️ Combat Stats</h4>
                        <div class="info-item">
                            <span class="info-label">Offense</span>
                            <span class="info-value">${soldier.offense}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Defense</span>
                            <span class="info-value">${soldier.defense}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Grit</span>
                            <span class="info-value">${soldier.grit}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Leadership</span>
                            <span class="info-value">${soldier.leadership}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Total Skill</span>
                            <span class="info-value">${soldier.total_skill}</span>
                        </div>
                    </div>

                    <div class="info-section">
                        <h4>📊 Service Record</h4>
                        <div class="info-item">
                            <span class="info-label">Missions</span>
                            <span class="info-value">${soldier.missions_completed}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Successful</span>
                            <span class="info-value">${soldier.successful_missions}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Kills</span>
                            <span class="info-value">${soldier.kills}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Status</span>
                            <span class="info-value">${this.capitalizeFirst(soldier.status)}</span>
                        </div>
                    </div>

                    ${soldier.background ? `
                        <div class="info-section background-info">
                            <h4>🎖️ Background</h4>
                            <div class="background-text">${soldier.background}</div>
                        </div>
                    ` : ''}
                </div>
            </div>
        `;
    }

    closeSoldierDetails() {
        document.getElementById('soldier-details').style.display = 'none';
    }

    // Utility function to capitalize first letter
    capitalizeFirst(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    async startGame() {
        try {
            await this.api('/api/new_game', 'POST');
            await this.loadGameStats();
            await this.generateNewMission();
        } catch (error) {
            console.error('Failed to start game:', error);
            this.showError('Failed to start game. Please try again.');
        }
    }

    async generateNewMission() {
        try {
            this.showLoading();
            const response = await this.api('/api/mission');
            this.currentMission = response.mission;
            this.displayMission();
            this.showPanel('mission');
        } catch (error) {
            console.error('Failed to generate mission:', error);
            this.showError('Failed to generate mission. Please try again.');
        }
    }

    async acceptMission() {
        try {
            this.showLoading();
            const response = await this.api('/api/squads');
            this.squads = response.squads;
            this.displaySquads();
            this.showPanel('squad');
        } catch (error) {
            console.error('Failed to load squads:', error);
            this.showError('Failed to load squads. Please try again.');
        }
    }

    async rejectMission() {
        try {
            this.showLoading();
            const response = await this.api('/api/reject_mission', 'POST');
            this.gameStats.cities_destroyed = response.cities_destroyed;
            this.updateGameStats();

            // Show rejection consequences
            this.showNotification('Mission Rejected', 'The city has been destroyed...', 'danger');

            // Generate new mission after delay and ensure proper display
            setTimeout(async () => {
                await this.generateNewMission();
                // Force refresh the mission display
                this.displayMission();
                this.showPanel('mission');
            }, 3000);
        } catch (error) {
            console.error('Failed to reject mission:', error);
            this.showError('Failed to reject mission. Please try again.');
        }
    }

    async deploySquad() {
        if (!this.selectedSquad) {
            this.showError('Please select a squad to deploy.');
            return;
        }

        try {
            this.showLoading();
            const response = await this.api('/api/deploy', 'POST', {
                squad_id: this.selectedSquad.id
            });

            this.displayBattleResults(response);
            this.showPanel('battle');

            // Update stats
            this.gameStats.missions_completed++;
            this.updateGameStats();
        } catch (error) {
            console.error('Failed to deploy squad:', error);
            this.showError('Failed to deploy squad. Please try again.');
        }
    }

    async continueOperations() {
        await this.generateNewMission();
    }

    displayMission() {
        const mission = this.currentMission;
        const kaiju = mission.kaiju;
        const location = mission.location;

        document.getElementById('kaiju-name').textContent = kaiju.name_english;
        document.getElementById('kaiju-designation').textContent = `(${kaiju.name_monster})`;
        document.getElementById('kaiju-form').textContent = `${kaiju.size.charAt(0).toUpperCase() + kaiju.size.slice(1)} ${kaiju.creature}`;
        document.getElementById('kaiju-material').textContent = kaiju.material;
        document.getElementById('kaiju-characteristic').textContent = kaiju.characteristic;
        document.getElementById('kaiju-weapon').textContent = kaiju.weapon;
        document.getElementById('kaiju-offense').textContent = kaiju.offense;
        document.getElementById('kaiju-defense').textContent = kaiju.defense;
        document.getElementById('kaiju-speed').textContent = kaiju.speed;
        document.getElementById('kaiju-special').textContent = kaiju.special;
        document.getElementById('kaiju-difficulty').textContent = kaiju.difficulty;
        document.getElementById('mission-location').textContent = location.city;

        // Update alert level based on difficulty
        const alertLevel = this.getThreatLevel(kaiju.difficulty);
        document.getElementById('alert-level').textContent = `THREAT LEVEL: ${alertLevel}`;
        document.getElementById('alert-level').className = `alert-level ${alertLevel.toLowerCase()}`;
    }

    displaySquads() {
        const container = document.getElementById('squads-container');
        container.innerHTML = '';

        this.squads.forEach(squad => {
            const squadCard = document.createElement('div');
            squadCard.className = 'squad-card';
            squadCard.setAttribute('data-squad-id', squad.id);

            // Build leadership info display
            let leadershipHTML = '';
            if (squad.leader) {
                const leader = squad.leader;
                leadershipHTML = `
                    <div class="leadership-info">
                        <div class="leader-display">
                            <span class="leader-icon">👑</span>
                            <span class="leader-name">${leader.name}</span>
                            <span class="leader-stat">Leadership: ${leader.leadership}</span>
                        </div>
                        ${leader.bonus_attack > 0 ? `
                            <div class="leadership-bonus">
                                <span class="bonus-text">Squad Bonus:</span>
                                <span class="bonus-stats">+${leader.bonus_attack} ATK/DEF, +${leader.bonus_grit} GRT</span>
                            </div>
                        ` : ''}
                    </div>
                `;
            }

            // Build threat assessment display
            let threatAssessmentHTML = '';
            if (squad.threat_assessment) {
                const risk = squad.threat_assessment.casualty_risk;
                const riskClass = risk.toLowerCase();
                threatAssessmentHTML = `
                    <div class="threat-assessment">
                        <div class="risk-indicator ${riskClass}">
                            <span class="risk-label">Casualty Risk:</span>
                            <span class="risk-value">${risk}</span>
                        </div>
                        <div class="squad-metrics">
                            <span class="metric">ATK: ${squad.threat_assessment.total_offense}</span>
                            <span class="metric">DEF: ${squad.threat_assessment.total_defense}</span>
                            <span class="metric">AVG: ${squad.threat_assessment.avg_skill}</span>
                        </div>
                        <div class="tactical-note">
                            ${this.getTacticalNote(squad.threat_assessment)}
                        </div>
                    </div>
                `;
            }

            squadCard.innerHTML = `
                <div class="squad-header">
                    <h3 class="squad-name">${squad.name}</h3>
                    <span class="squad-size">${squad.soldiers.length} soldiers</span>
                </div>
                ${leadershipHTML}
                ${threatAssessmentHTML}
                <div class="soldiers-grid">
                    ${squad.soldiers.map(soldier => `
                        <div class="soldier-row ${soldier.is_leader ? 'leader-row' : ''}">
                            <span class="soldier-name">
                                ${soldier.is_leader ? '👑 ' : ''}Lv.${soldier.level} ${soldier.name}
                            </span>
                            <span class="soldier-stats">O:${soldier.offense} D:${soldier.defense} G:${soldier.grit} L:${soldier.leadership}</span>
                        </div>
                    `).join('')}
                </div>
            `;

            squadCard.addEventListener('click', () => {
                this.selectSquad(squad, squadCard);
            });

            container.appendChild(squadCard);
        });
    }

    selectSquad(squad, squadCard) {
        // Remove previous selection
        document.querySelectorAll('.squad-card').forEach(card => {
            card.classList.remove('selected');
        });

        // Select new squad
        squadCard.classList.add('selected');
        this.selectedSquad = squad;
        document.getElementById('deploy-squad-btn').disabled = false;
    }

    displayBattleResults(battleData) {
        const resultContainer = document.getElementById('battle-result');
        const casualtiesContainer = document.getElementById('casualties-report');

        // Display battle intro and outcome
        const successClass = battleData.mission_success ? 'battle-success' : 'battle-failure';

        let battleHTML = `
            <div class="${successClass}">
                <h3>⚔️ BATTLE REPORT: ${battleData.kaiju.name}</h3>
                <p><strong>Location:</strong> ${battleData.kaiju.location}</p>
                <p><strong>Threat Level:</strong> ${battleData.kaiju.difficulty}</p>
            </div>

            <div class="battle-intro">
                <h4>📡 Pre-Battle Assessment</h4>
                ${battleData.battle_intro.map(line => `<p>${line}</p>`).join('')}
            </div>

            <div class="soldier-reports">
                <h4>🎬 Combat Reports</h4>
                ${battleData.soldier_reports.map((report, index) => `
                    <div class="soldier-report ${report.status} ${report.is_leader ? 'leader-report' : ''}" style="animation-delay: ${index * 0.8}s">
                        <h5>🪖 ${report.is_leader ? '👑 ' : ''}${report.name} (Level ${report.pre_battle_stats.level})${report.is_leader ? ' - Squad Leader' : ''}</h5>
                        <div class="battle-narrative">
                            ${report.battle_narrative.map((line, lineIndex) => `<p class="narrative-line" style="animation-delay: ${(index * 0.8) + (lineIndex * 0.3)}s">${line}</p>`).join('')}
                        </div>
                    </div>
                `).join('')}
            </div>

            <div class="mission-outcome ${successClass}">
                <h4>📊 Mission Outcome</h4>
                ${battleData.mission_outcome.map(line => `<p>${line}</p>`).join('')}
            </div>
        `;

        resultContainer.innerHTML = battleHTML;

        // Display detailed casualties and promotions
        let casualtiesHTML = '<h4>📊 Post-Battle Analysis</h4>';

        if (battleData.casualties > 0) {
            casualtiesHTML += `
                <div class="casualty-info">
                    <h5>💀 Fallen Heroes (${battleData.casualties})</h5>
                    ${battleData.casualty_list.map(name => `<p>• ${name} - Gave their life for the mission</p>`).join('')}
                    <p><em>They will be remembered as heroes who made the ultimate sacrifice.</em></p>
                </div>
            `;
        }

        if (Object.keys(battleData.promotion_details).length > 0) {
            casualtiesHTML += '<div class="promotions"><h5>🎖️ Promotions & Advancement</h5>';
            Object.entries(battleData.promotion_details).forEach(([soldierName, details]) => {
                casualtiesHTML += `
                    <div class="promotion-detail">
                        <h6>🌟 ${soldierName}</h6>
                        <p>Level ${details.old_stats.level} → Level ${details.new_stats.level}</p>
                        <div class="stat-improvements">
                            <span>ATK: ${details.old_stats.offense}→${details.new_stats.offense}</span>
                            <span>DEF: ${details.old_stats.defense}→${details.new_stats.defense}</span>
                            <span>GRT: ${details.old_stats.grit}→${details.new_stats.grit}</span>
                            <span>LDR: ${details.old_stats.leadership}→${details.new_stats.leadership}</span>
                        </div>
                    </div>
                `;
            });
            casualtiesHTML += '</div>';
        }

        if (battleData.recruitment_details && battleData.recruitment_details.length > 0) {
            casualtiesHTML += '<div class="recruitment"><h5>📋 New Recruits</h5>';
            casualtiesHTML += '<p>High Command has dispatched replacement personnel:</p>';
            battleData.recruitment_details.forEach(recruit => {
                casualtiesHTML += `
                    <div class="recruit-detail">
                        <h6>🆕 ${recruit.name}</h6>
                        <p><em>Background: ${recruit.background}</em></p>
                        <div class="recruit-stats">
                            <span>ATK: ${recruit.stats.offense}</span>
                            <span>DEF: ${recruit.stats.defense}</span>
                            <span>GRT: ${recruit.stats.grit}</span>
                            <span>LDR: ${recruit.stats.leadership}</span>
                        </div>
                    </div>
                `;
            });
            casualtiesHTML += '</div>';
        }

        if (battleData.casualties === 0 && Object.keys(battleData.promotion_details).length === 0 && (!battleData.recruitment_details || battleData.recruitment_details.length === 0)) {
            casualtiesHTML += '<p>All soldiers survived without major casualties or promotions this mission.</p>';
        }

        casualtiesContainer.innerHTML = casualtiesHTML;

        // Scroll to battle results
        setTimeout(() => {
            document.getElementById('battle-result').scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }, 500);
    }

    getThreatLevel(difficulty) {
        if (difficulty <= 20) return 'LOW';
        if (difficulty <= 35) return 'MODERATE';
        if (difficulty <= 50) return 'HIGH';
        if (difficulty <= 65) return 'CRITICAL';
        return 'EXTREME';
    }

    async loadGameStats() {
        try {
            const response = await this.api('/api/stats');
            this.gameStats = response;
            this.updateGameStats();
        } catch (error) {
            console.error('Failed to load game stats:', error);
        }
    }

    updateGameStats() {
        document.getElementById('missions-count').textContent = this.gameStats.missions_completed;
        document.getElementById('cities-destroyed').textContent = this.gameStats.cities_destroyed;
    }

    showPanel(panelName) {
        // Hide all panels
        document.querySelectorAll('.panel').forEach(panel => {
            panel.style.display = 'none';
        });

        // Show selected panel
        document.getElementById(`${panelName}-panel`).style.display = 'block';
    }

    showLoading() {
        // Could show a loading indicator
        console.log('Loading...');
    }

    showError(message) {
        alert(`Error: ${message}`);
    }

    showNotification(title, message, type = 'info') {
        // Simple notification - could be enhanced with a proper notification system
        console.log(`${title}: ${message}`);
        alert(`${title}\n${message}`);
    }

    async api(endpoint, method = 'GET', data = null) {
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include'  // Include cookies for session management
        };

        if (data) {
            options.body = JSON.stringify(data);
        }

        const response = await fetch(endpoint, options);

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        return await response.json();
    }

    getTacticalNote(assessment) {
        const risk = assessment.casualty_risk;
        const kaijuDiff = assessment.kaiju_difficulty;
        const avgSkill = assessment.avg_skill;

        if (risk === 'Low') {
            return "✅ Squad is well-equipped for this threat level";
        } else if (risk === 'Moderate') {
            return "⚠️ Expect some casualties but mission should succeed";
        } else if (risk === 'High') {
            return "🔥 Dangerous mission - significant losses expected";
        } else {
            return "💀 EXTREME DANGER - Squad may be overwhelmed";
        }
    }
}

// Initialize the game when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new KaijuGame();
});