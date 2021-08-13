using System;
using KaijuGame.Consoles;
using SadConsole;
using SadConsole.Input;
using SadRogue.Primitives;
using Console = SadConsole.Console;

namespace KaijuGame
{
    class Program
    {
        private static Container MainConsole;
        private static void Main(string[] args)
        {
            Settings.WindowTitle = "Kaiju Text Adventue";
            // Setup the engine and create the main window.
            Game.Create(80,31);

            // Hook the start event so we can add consoles to the system.
            Game.Instance.OnStart = Init;
            SadConsole.Game.Instance.FrameUpdate += Instance_FrameUpdate;
            // Start the game.
            Game.Instance.Run();
            Game.Instance.Dispose();
        }

        private static void Instance_FrameUpdate(object sender, GameHost e)
        {
            // Called each logic update.
            //if (!_characterWindow.IsVisible)
            {
                // This block of code cycles through the consoles in the SadConsole.Engine.ConsoleRenderStack, showing only a single console
                // at a time. This code is provided to support the custom consoles demo. If you want to enable the demo, uncomment one of the lines
                // in the Initialize method above.
                if (SadConsole.GameHost.Instance.Keyboard.IsKeyReleased(Keys.F1))
                {
                    MainConsole.MoveNextConsole();
                }
                else if (SadConsole.GameHost.Instance.Keyboard.IsKeyReleased(Keys.F5))
                {
                    SadConsole.Game.Instance.ToggleFullScreen();

                }
            }
        }

        private static void Init()
        {
            // This code uses the default console created for you at start
            MainConsole = new Container();

            Game.Instance.Screen = MainConsole;
            Game.Instance.DestroyDefaultStartingConsole();

        }
    }
}