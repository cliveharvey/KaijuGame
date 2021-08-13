using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KaijuGame.Entities;


namespace KaijuGame.TextDump
{
    class BattleText
    {
        readonly Random r = new Random();
        private List<string> movementS = new List<string>(){
            "reached to an elevated position",
            "moved towards the target",
            "took cover",
            "moved to intercept the target",
            "started securing civilians",
            "moved to block the targets escape",
        };
        private List<string> movementF = new List<string>(){
            "took cover in the open",
            "ran recklessly towards the target",
            "took position in a rickety building",
            "moved right under the target",
            "began shooting immediately",
            "couldnt keep up with the squad",
        };
        private List<string> actionS = new List<string>(){
            "targeted the beasts exposed areas",
            "pulled civilians to safety",
            "helped team members avoid the beasts attacks",
            "secured the area",
            "suppressed the beasts movements",
            "overwhelmed the beast with attacks",
        };
        private List<string> actionF = new List<string>(){
            "shot recklessly at the beast",
            "had equipment failure",
            "cowered behind cover",
            "lost their bearings",
            "was trampled by excaping civilians",
            "attacked the beast head on",

        };
        private List<string> outcomeS = new List<string>(){
            "Civilians had time to escape!",
            "The beast became distracted from its rampage!",
            "Assets were secured!",
            "The beast routed away from civilians!",
            "The beast began to retreat!",
            "Civilians were medevaced!",
        };
        private List<string> outcomeF = new List<string>(){
            "More buildings were destroyed",
            "Many were cut down by the beast",
            "The beast moved unhampered",
            "The beast roared out in victory",
            "The beast continued its assault",
            "Fires broke out everywhere",
        };
        private List<string> injury = new List<string>(){
            "was flung through the air by the beasts vicious attack",
            "was hit by debris from the beasts attack",
            "was hit by falling cement from the damaged buildings",
            "was unabled to get out of the way of an attack",
            "was caught off guard by the beast",
        };

        public BattleText()
        {

        }

        public void BatteTextSummary(List<string> text, Soldier member)
        {
            text.Add(member.Name + " " + MovementText(member.Success));
            text.Add(member.Name + " " + ActionText(member.Success));
            text.Add(OutcomeText(member.Success));
            if (member.Status>0)
            {
                text.Add(member.Name + " " + InjuryText());
            }
            text.Add("");
        }

        private string MovementText(bool success)
        {
            var text = "";
            if (success)
            {
                var index = r.Next(movementS.Count - 1);
                text = movementS[index];
                movementS.RemoveAt(index);
            }
            else
            {
                var index = r.Next(movementF.Count - 1);
                text = movementF[index];
                movementF.RemoveAt(index);
            }
            return text;
        }

        private string ActionText(bool success)
        {
            var text = "";
            if (success)
            {
                var index = r.Next(actionS.Count - 1);
                text = actionS[index];
                actionS.RemoveAt(index);
            }
            else
            {
                var index = r.Next(actionF.Count - 1);
                text = actionF[index];
                actionF.RemoveAt(index);
            }
            return text;
        }

        private string OutcomeText(bool success)
        {
            var text = "";
            if (success)
            {
                var index = r.Next(outcomeS.Count - 1);
                text = outcomeS[index];
                outcomeS.RemoveAt(index);
            }
            else
            {
                var index = r.Next(outcomeF.Count - 1);
                text = outcomeF[index];
                outcomeF.RemoveAt(index);
            }
            return text;
        }

        private string InjuryText()
        {
            var text = "";
            var index = r.Next(injury.Count - 1);
            text = injury[index];
            injury.RemoveAt(index);
            return text;
        }


    }
}
