using KaijuGame.Consoles.Screens;
using SadConsole;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Consoles
{
    class Container : ScreenObject
    {
        private int currentConsoleIndex = -1;
        private IScreenObject selectedConsole;
        private HeaderConsole headerConsole;
        private ScreenObject selectedConsoleContainer;

        CustomConsole[] consoles;

        public Container()
        {
            headerConsole = new HeaderConsole();
            selectedConsoleContainer = new ScreenObject();
            selectedConsoleContainer.Position = (0, headerConsole.AbsoluteArea.MaxExtentY + 1);

            consoles = new CustomConsole[]
            {
                new CustomConsole(new MainScreenConsole(), "Main Screen", "Beep Boop" ),
                new CustomConsole(new BaseConsole(){KaijuAttack = MoveNextConsole }, "Main Base", "Current Base Status" ),
                new CustomConsole(new MissionConsole(){DeployTeam = MoveNextConsole }, "Mission Summary", "The reports are coming in!" ),
                new CustomConsole(new BattleConsole(){ExtractTeam = MoveNextConsole }, "Battle Report", "Beep Boop" ),
                new CustomConsole(new RewardConsole(), "Rewards", "Beep Boop" ),
            };


            MoveNextConsole();
        }
        public void MoveNextConsole()
        {
            currentConsoleIndex++;

            if (currentConsoleIndex >= consoles.Length)
                currentConsoleIndex = 0;

            selectedConsole = consoles[currentConsoleIndex].Console;

            Children.Clear();
            Children.Add(headerConsole);
            Children.Add(selectedConsoleContainer);

            selectedConsoleContainer.Children.Clear();
            selectedConsoleContainer.Children.Add(selectedConsole);

            selectedConsole.IsVisible = true;
            selectedConsole.IsFocused = true;
            //selectedConsole.Position = new Point(0, 2);

            GameHost.Instance.FocusedScreenObjects.Set(selectedConsole);
            headerConsole.SetConsole(consoles[currentConsoleIndex].Title, consoles[currentConsoleIndex].Summary);
        }
    }
}
