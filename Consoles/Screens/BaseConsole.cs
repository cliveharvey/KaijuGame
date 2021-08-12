using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Console = SadConsole.Console;
using System.Threading.Tasks;
using SadConsole.UI.Themes;
using SadRogue.Primitives;
using SadConsole.UI.Controls;
using SadConsole;

namespace KaijuGame.Consoles.Screens
{
    internal class BaseConsole : SadConsole.UI.ControlsConsole
    {
        private Label dateDisplay;
        private ProgressBar prog1;
        private DateTime gameDate;
        private int daysPassedSinceLastAttack;
        private Random randy = new Random();
        public Action KaijuAttack;
        private readonly SadConsole.Components.Timer progressTimer;

        public BaseConsole() : base(80, 25)
        {
            int x = 5;

            var selButton = new SelectionButton(24, 3)
            {
                Text = "Barracks",
                Position = new Point(x, 3),
                Theme = new ButtonLinesTheme()

            };
            Controls.Add(selButton);

            var selButton1 = new SelectionButton(24, 3)
            {
                Text = "R & D",
                Position = new Point(x, 6),
                Theme = new ButtonLinesTheme()
            };
            Controls.Add(selButton1);

            var selButton2 = new SelectionButton(24, 3)
            {
                Text = "World Status",
                Position = new Point(x, 9),
                Theme = new ButtonLinesTheme()
            };
            Controls.Add(selButton2);

            var selButton3 = new SelectionButton(24, 3)
            {
                Text = "Base Upgrades",
                Position = new Point(x, 12),
                Theme = new ButtonLinesTheme()
            };
            Controls.Add(selButton3);

            prog1 = new ProgressBar(18, 1, HorizontalAlignment.Left)
            {
                DisplayTextAlignment = HorizontalAlignment.Left,
                Position = new Point(62, 22)
            };
            Controls.Add(prog1);

            progressTimer = new SadConsole.Components.Timer(TimeSpan.FromSeconds(0.5));
            progressTimer.TimerElapsed += (timer, e) => { prog1.Progress = prog1.Progress >= 1f ? 0f : prog1.Progress + 0.1f; };

            dateDisplay = new Label(GetStartDate())
            {
                Position = new Point(62, 20),
            };
            Controls.Add(dateDisplay);

            SadComponents.Add(progressTimer);
        }

        private string GetStartDate()
        {
            DateTime start = new DateTime(1995, 1, 1);
            int range = (DateTime.Today - start).Days;
            gameDate = start.AddDays(randy.Next(range));
            return gameDate.ToLongDateString();
        }

        private bool isThereKaijuAttack()
        {
            for(int i = 0; i < daysPassedSinceLastAttack; i++)
            {
                if (randy.Next(1, 21) == 20 || daysPassedSinceLastAttack == 20)
                    return true;
                continue;
            }
            return false;
        }

        public override void Update(TimeSpan delta)
        {
            base.Update(delta);

            if(prog1.Progress == 1)
            {
                gameDate = gameDate.AddDays(1);
                dateDisplay.DisplayText = gameDate.ToLongDateString();
                prog1.Progress = 0f;
                if (isThereKaijuAttack())
                {
                    KaijuAttack?.Invoke();
                    daysPassedSinceLastAttack = 0;
                }
                else
                {
                    daysPassedSinceLastAttack++;
                }
            }
        }
    }
}
