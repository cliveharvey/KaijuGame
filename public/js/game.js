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
        // Start game
        document.getElementById('start-game-btn').addEventListener('click', () => {
            this.startGame();
        });

        // Mission actions
        document.getElementById('accept-mission-btn').addEventListener('click', () => {
            this.acceptMission();
        });

        document.getElementById('reject-mission-btn').addEventListener('click', () => {
            this.rejectMission();
        });

        document.getElementById('new-mission-btn').addEventListener('click', () => {
            this.generateNewMission();
        });

        // Squad actions
        document.getElementById('deploy-squad-btn').addEventListener('click', () => {
            this.deploySquad();
        });

        document.getElementById('back-to-mission-btn').addEventListener('click', () => {
            this.showPanel('mission');
        });

        // Battle actions
        document.getElementById('continue-operations-btn').addEventListener('click', () => {
            this.continueOperations();
        });
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

            // Generate new mission after delay
            setTimeout(() => {
                this.generateNewMission();
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

            squadCard.innerHTML = `
                <div class="squad-header">
                    <h3 class="squad-name">${squad.name}</h3>
                    <span class="squad-size">${squad.soldiers.length} soldiers</span>
                </div>
                <div class="soldiers-grid">
                    ${squad.soldiers.map(soldier => `
                        <div class="soldier-row">
                            <span class="soldier-name">Lv.${soldier.level} ${soldier.name}</span>
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
                    <div class="soldier-report ${report.status}" style="animation-delay: ${index * 0.2}s">
                        <h5>🪖 ${report.name} (Level ${report.pre_battle_stats.level})</h5>
                        <div class="battle-narrative">
                            ${report.battle_narrative.map(line => `<p class="narrative-line">${line}</p>`).join('')}
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

        if (battleData.casualties === 0 && Object.keys(battleData.promotion_details).length === 0) {
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
}

// Initialize the game when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new KaijuGame();
});