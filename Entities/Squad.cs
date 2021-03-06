using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Entities
{
    class Squad
    {
        private string squadName;
        private List<Soldier> members;
        public Squad(string name, List<Soldier> soldiers)
        {
            squadName = name;
            members = soldiers;
        }

        public string SquadName
        {
            get => squadName;
            set => squadName = value;
        }

        public List<Soldier> Members
        {
            get => members;
            set => members = value;
        }

        public bool SquadCombat(int difficulty)
        {
            var success = 0;
            foreach (var soldier in members)
            {
                if (soldier.Combat(difficulty))
                    success++;
            }
            return success > 3;
        }
    }
}
