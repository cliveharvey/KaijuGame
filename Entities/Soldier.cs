using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Entities
{
    enum SoldierStatus
    {
        Alive,
        Skratched,
        Injured,
        KIA
    }
    class Soldier
    {
        private string name;
        private int skill;
        private SoldierStatus status;

        public Soldier(string soldierName, int soldierSkill) {
            name = soldierName;
            skill = soldierSkill;
            status = SoldierStatus.Alive;
        }

        public string Name
        {
            get => name;
            set => name = value;
        }

        public int Skill
        {
            get => skill;
            set => skill = value;
        }

        public SoldierStatus Status
        {
            get => status;
            set => status = value;
        }

        public bool Combat (int difficulty)
        {
            //Makes a combat roll based on soldiers skill. 
            var combatRoll = new Random().Next(Skill);
            //Soldiers Status changes based on combat roll
            if (combatRoll < difficulty - 30)
            {
                Status = SoldierStatus.KIA;
                return false;
            }
            else if (combatRoll < difficulty - 20)
            {
                Status = SoldierStatus.Injured;
                return false;
            }
            else if (combatRoll < difficulty - 10)
            {
                Status = SoldierStatus.Skratched;
            }
            return true;
        }
    }
}
