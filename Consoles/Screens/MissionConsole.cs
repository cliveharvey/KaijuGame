using System;
using Console = SadConsole.Console;
using SadConsole;
using SadRogue.Primitives;
using SadConsole.UI.Controls;
using SadConsole.UI.Themes;
using KaijuGame.Entities;


namespace KaijuGame.Consoles.Screens
{
    internal class MissionConsole : Console
    {
        public Action DeployTeam { get; set; }

        private readonly Console missionBriefView;
        private readonly Console userActionView;

        public MissionConsole() : base(80, 31)
        {
            missionBriefView = new Console(80, 15);
            userActionView = new Console(80, 10);

            missionBriefView.Fill(Color.White, Color.Red, 0);
            userActionView.Fill(Color.White, Color.Blue, 0);

            UseMouse = true;

            // Add the consoles to the list.
            Children.Add(missionBriefView);
            Children.Add(userActionView);


            // Setup main view
            missionBriefView.Position = new Point(0, 0);

            // Setup sub view
            userActionView.Position = new Point(0, 16);

            missionBriefView.Children.Add(new WritingConsole());
            userActionView.Children.Add(new DeployTeamConsole() { DeployButton = DeployTheTeam });

            IsVisible = false;
        }

        public void DeployTheTeam()
        {
            DeployTeam?.Invoke();
        }
    }

    internal class DeployTeamConsole : SadConsole.UI.ControlsConsole
    {
        public Action DeployButton { get; set; }
        public DeployTeamConsole() : base(80, 15)
        {
            var button = new Button(20, 3)
            {
                Text = "Deploy Troops",
                Position = new Point(1, 0),
                Theme = new ButtonLinesTheme()
            };
            button.Click += (s, a) => { DeployButton?.Invoke(); };
            Controls.Add(button);

            button = new Button(20, 3)
            {
                Text = "Lets stay home",
                Position = new Point(1, 3),
                Theme = new ButtonLinesTheme()
            };
            button.Click += (s, a) => SadConsole.UI.Window.Message("This is what you're paid for soldier, now do your duty!", "Close");
            Controls.Add(button);
        }
    }

    internal class WritingConsole : Console
    {
        SadConsole.Instructions.DrawString typingInstruction;
        public WritingConsole() : base(80, 15)
        {
            var location = new Location();
            string[] text = new string[]
            {
                "A terrifying new breed of Kaiju has been spotted terrorizing " + location.City + "!",
                "It has already toppled the CN tower, and is making its way towards the Clio office!",
            };

            typingInstruction = new SadConsole.Instructions.DrawString(SadConsole.ColoredString.Parse(string.Join("\r\n", text)));
            typingInstruction.TotalTimeToPrint = 7; // 0.25 seconds per line of text
            Cursor.Position = new Point(1, 1);
            Cursor.IsEnabled = false;
            Cursor.IsVisible = true;
            typingInstruction.Cursor = Cursor;
            SadComponents.Add(typingInstruction);
        }
    }
}
