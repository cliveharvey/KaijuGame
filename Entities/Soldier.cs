using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Entities
{
    class Soldier
    {
        private string name;
        private int skill;

        public Soldier(string soldierName, int soldierSkill) {
            name = soldierName;
            skill = soldierSkill;
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
    }
}
