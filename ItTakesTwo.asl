//Made by Ironhead39 and Hyper - Modified by Lemuura
state("ItTakesTwo")
{
	bool isLoading: "ItTakesTwo.exe", 0x77E856C;
	bool isCutscene: "ItTakesTwo.exe", 0x7610E98;
	string255 levelString: "ItTakesTwo.exe", 0x780e460, 0x180, 0x368, 0x8, 0x1b8, 0x0;
	string255 checkPointString: "ItTakesTwo.exe", 0x780e460, 0x180, 0x368, 0x8, 0x1d8, 0x0;
	string255 cutsceneString: "ItTakesTwo.exe", 0x780e460, 0x180, 0x2b0, 0x0, 0x390, 0x2a0, 0x788, 0x0;
	byte skippable: "ItTakesTwo.exe", 0x780e460, 0x180, 0x2b0, 0x0, 0x390, 0x318; // Any value above 0 is skippable
}

state("ItTakesTwo_Trial")
{
	bool isLoading: "ItTakesTwo_Trial.exe", 0x77E856C;
	bool isCutscene: "ItTakesTwo_Trial.exe", 0x7610E98;
	string255 levelString: "ItTakesTwo_Trial.exe", 0x780e460, 0x180, 0x368, 0x8, 0x1b8, 0x0;
	string255 checkPointString: "ItTakesTwo_Trial.exe", 0x780e460, 0x180, 0x368, 0x8, 0x1d8, 0x0;
	string255 cutsceneString: "ItTakesTwo_Trial.exe", 0x780e460, 0x180, 0x2b0, 0x0, 0x390, 0x2a0, 0x788, 0x0;
	byte skippable: "ItTakesTwo_Trial.exe", 0x780e460, 0x180, 0x2b0, 0x0, 0x390, 0x318;
}

init
{
	int cutsceneCount = 0; // Initialize cutscene counter
	vars.delayTimer = 0;
	vars.delayTimerTimestamp = 0;
	vars.lastCutscene = "";
	vars.lastCutsceneOld = "";
	vars.checkpointCount = 0;
	vars.timePassed = 0; // Debug value, will remove in the future.
	vars.avgTimePassed = new List<int>() { }; // Debug value, will remove in the future.
	vars.iceCaveDone = 0;
}

startup
{
	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var timingMessage = MessageBox.Show(
			"This game uses RTA w/o Loads as the main timing method.\n"
			+ "LiveSplit is currently set to show Real Time (RTA).\n"
			+ "Would you like to set the timing method to RTA w/o Loads?",
			"It Takes Two | LiveSplit",
			MessageBoxButtons.YesNo, MessageBoxIcon.Question
		);
		if (timingMessage == DialogResult.Yes)
		{
			timer.CurrentTimingMethod = TimingMethod.GameTime;
		}
	}

	vars.SetTextComponent = (Action<string, string>)((id, text) =>
	{
		var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
		var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
		if (textSetting == null)
		{
			var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
			var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
			timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
			textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
			textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
		}
		if (textSetting != null)
			textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
	});

	// Optional Settings
	settings.Add("cpCount", false, "Checkpoint Counter");
	settings.Add("commGold", false, "Comm Gold Resets");
	settings.Add("levelReset", false, "IL Resets");

	// Optional Splits
	settings.Add("optionalSplits", false, "Optional Splits");
		settings.CurrentDefaultParent = "optionalSplits";
		settings.Add("shed", false, "The Shed");
		settings.Add("tree", false, "The Tree");
		settings.Add("rose", false, "Rose's Room");
		settings.Add("clock", false, "Cuckoo Clock");
		settings.Add("snow", false, "Snow Globe");
		settings.Add("garden", false, "Garden");
		settings.Add("attic", false, "The Attic");
		settings.Add("intermediaries", false, "Intermediaries (Deprecated)");

			settings.CurrentDefaultParent = "shed";
			settings.Add("biting", false, "Biting the Dust");
			settings.Add("depths", false, "The Depths");
			settings.Add("wired", false, "Wired Up");

				settings.CurrentDefaultParent = "biting";
				settings.Add("vacuumBattle", false, "Vacuum Battle Cutscene");

				settings.CurrentDefaultParent = "depths";
				settings.Add("preBossDoubleInteract", false, "Pre Boss Double Interact");

				settings.CurrentDefaultParent = "wired";

			settings.CurrentDefaultParent = "tree";
			settings.Add("fresh", false, "Fresh Air");
			settings.Add("captured", false, "Captured");
			settings.Add("rooted", false, "Deeply Rooted");
			settings.Add("extermination", false, "Extermination");
			settings.Add("getaway", false, "Getaway");

				settings.CurrentDefaultParent = "fresh";

				settings.CurrentDefaultParent = "captured";
				settings.Add("tug", false, "Tug of War");

				settings.CurrentDefaultParent = "rooted";
				settings.Add("boatStart", false, "Boat Start");
				settings.Add("boatSwarm", false, "Boat Swarm CP");
				settings.Add("darkroomStart", false, "Darkroom Start");
				settings.Add("secondLantern", false, "Second Lantern");
				settings.Add("thirdLantern", false, "Third Lantern");
				settings.Add("beetleElevator", false, "Beetle Elevator");
				settings.Add("beetleArena", false, "Beetle Arena");

				settings.CurrentDefaultParent = "extermination";
				settings.Add("planeIntro", false, "Plane Intro");
				settings.Add("smashWood", false, "Smash In Wood");

				settings.CurrentDefaultParent = "getaway";
				settings.Add("gliderHalfway", false, "Glider halfway through");

			settings.CurrentDefaultParent = "rose";
			settings.Add("pillow", false, "Pillow Fort");
			settings.Add("spaced", false, "Spaced Out");
			settings.Add("hopscotch", false, "Hopscotch");
			settings.Add("train", false, "Train Station");
			settings.Add("dino", false, "Dino Land");
			settings.Add("pirates", false, "Pirates Ahoy");
			settings.Add("circus", false, "The Greatest Show");
			settings.Add("castle", false, "Once Upon a Time");
			settings.Add("dungeon", false, "Dungeon Crawler");
			settings.Add("queen", false, "The Queen");

				settings.CurrentDefaultParent = "pillow";

				settings.CurrentDefaultParent = "spaced";
				settings.Add("firstPlatform", false, "First Portal Platform");
				settings.Add("eject", false, "UFO Eject Button");

				settings.CurrentDefaultParent = "hopscotch";
				settings.Add("grind", false, "Grind Section CP");
				settings.Add("void", false, "Void World");
				settings.Add("kaleidoscope", false, "Kaleidoscope");

				settings.CurrentDefaultParent = "train";

				settings.CurrentDefaultParent = "dino";
				settings.Add("pteranodon", false, "Pteranodon Crash");

				settings.CurrentDefaultParent = "pirates";
				settings.Add("ships", false, "Ships Intro");
				settings.Add("pirateBoss", false, "Boss Intro");

				settings.CurrentDefaultParent = "circus";
				settings.Add("trapeeze", false, "Trapeeze");

				settings.CurrentDefaultParent = "castle";
				settings.Add("crane", false, "Crane Puzzle");

				settings.CurrentDefaultParent = "dungeon";
				settings.Add("crusherIntro", false, "Crusher Intro");
				settings.Add("chess", false, "Chess Intro");

				settings.CurrentDefaultParent = "queen";

			settings.CurrentDefaultParent = "clock";
			settings.Add("gates", false, "Gates of Time");
			settings.Add("clockworks", false, "Clockworks");
			settings.Add("blast", false, "A Blast from the Past");

				settings.CurrentDefaultParent = "gates";
				settings.Add("clocktown", false, "Clocktown Intro");
				settings.Add("hellTower", false, "Hell Tower");
				settings.Add("birdIntro", false, "Bird Intro");
				settings.Add("rightTowerDestroyed", false, "Right Tower Destroyed");

				settings.CurrentDefaultParent = "clockworks";
				settings.Add("statue", false, "Statue Room");
				settings.Add("wallJump", false, "Wall Jump Corridor");
				settings.Add("pocketWatch", false, "Pocket Watch Room");

				settings.CurrentDefaultParent = "blast";
				settings.Add("afterRewindSmash", false, "After Rewind Smash");

			settings.CurrentDefaultParent = "snow";
			settings.Add("warming", false, "Warming Up");
			settings.Add("village", false, "Winter Village");
			settings.Add("bti", false, "Beneath the Ice");
			settings.Add("slopes", false, "Slippery Slopes");

				settings.CurrentDefaultParent = "warming";

				settings.CurrentDefaultParent = "village";

				settings.CurrentDefaultParent = "bti";
				settings.Add("iceCave", false, "Ice Cave Finish");
				settings.Add("fish", false, "Fish RCP");

				settings.CurrentDefaultParent = "slopes";
				settings.Add("collapse", false, "Collapse RCP");
				settings.Add("playerAttraction", false, "Player Attraction RCP");

			settings.CurrentDefaultParent = "garden";
			settings.Add("fingers", false, "Green Fingers");
			settings.Add("weed", false, "Weed Whacking");
			settings.Add("trespassing", false, "Trespassing");
			settings.Add("frog", false, "Frog Pond");
			settings.Add("affliction", false, "Affliction");

				settings.CurrentDefaultParent = "fingers";
				settings.Add("cactus", false, "Cactus Combat Area");
				settings.Add("beanstalk", false, "Beanstalk Section");
				settings.Add("burrown", false, "Burrown Enemy");
				settings.Add("window", false, "Greenhouse Window");

				settings.CurrentDefaultParent = "weed";
				settings.Add("finalCombat", false, "Starting Final Combat RCP");
				settings.Add("cactusWaves", false, "Cactus Waves Intro");

				settings.CurrentDefaultParent = "trespassing";
				settings.Add("gnome", false, "Gnome CP");

				settings.CurrentDefaultParent = "frog";
				settings.Add("snail", false, "Snail Race");

				settings.CurrentDefaultParent = "affliction";
				settings.Add("joyIntro", false, "Joy Intro");
				settings.Add("joyPhase2", false, "Joy Phase 2");
				settings.Add("joyPhase3", false, "Joy Phase 3");

			settings.CurrentDefaultParent = "attic";
			settings.Add("stage", false, "Setting the Stage");
			settings.Add("rehearsal", false, "Rehearsal");
			settings.Add("symphony", false, "Symphony");
			settings.Add("turnUp", false, "Turn Up");
			settings.Add("finale", false, "A Grand Finale");

				settings.CurrentDefaultParent = "stage";
				settings.Add("trackRunner", false, "Track Runner");

				settings.CurrentDefaultParent = "rehearsal";

				settings.CurrentDefaultParent = "symphony";

				settings.CurrentDefaultParent = "turnUp";
				settings.Add("djElevator", false, "DJ Elevator");
				settings.Add("audioSurf", false, "Audio Surf");

				settings.CurrentDefaultParent = "finale";

	// DEBUG
	settings.CurrentDefaultParent = null;
	settings.Add("debugTextComponents", false, "[DEBUG] Show tracked values in layout");

}

isLoading
{
	// Delay timer countdown
	var timePassed = Environment.TickCount - vars.delayTimerTimestamp;
	vars.delayTimerTimestamp = Environment.TickCount;
	if (vars.delayTimer > 0)
	{
		var adjustment = vars.delayTimer - timePassed;
		if (adjustment <= 0)
		{
			vars.delayTimer = 0;
			return true;
		}
		if ((current.skippable <= 0 && old.skippable >= 1) || (vars.lastCutsceneOld != vars.lastCutscene && current.skippable >= 1))
        {
            vars.timePassed = 4000 - vars.delayTimer;
			if (vars.timePassed != 4000 && vars.timePassed != 0)
            {
				vars.avgTimePassed.Add(vars.timePassed);
			}
			vars.delayTimer = 0;
        }
		else
		{
			vars.delayTimer = adjustment;
			return true;
		}
	}

	// Exception clause, for any cutscenes that pause timer but shouldn't, or are otherwise problematic.
	vars.exception = new List<string>() 
    {
		"CS_Tree_WaspQueenBoss_Arena_Defeated",
		"CS_Tree_Escape_Chase_Outro",
		"CS_Tree_Escape_Plane_Combat", // Only skippable by Cody, capability blocked for May
		"CS_Tree_Escape_NoseDive_Intro", // Extremely short skippable window
		"CS_PlayRoom_Bookshelf_Elephant_Outro",
		"CS_Garden_Shrubbery_Shrubbery_Intro"
	};

	// Checks if skippable
    if ((current.skippable >= 1 && old.skippable <= 0) || (vars.lastCutsceneOld != vars.lastCutscene && current.skippable >= 1))
	{ 
		if (vars.exception.Contains(vars.lastCutscene))
        {
			vars.delayTimer = 0;
		}
		else
        {
			vars.delayTimer = 4000; // How long to delay loads during skippable cutscenes
			vars.timePassed = 4000;
		}
	} 

	if (current.isLoading)
		return true;
	if (current.levelString == "/Game/Maps/Main/Menu_BP")
		return true;
	if (current.levelString != "/Game/Maps/Main/Menu_BP")
		return false;
	return true;
}

update
{
	vars.lastCutsceneOld = vars.lastCutscene;
	if (current.cutsceneString == null) vars.lastCutscene = "null";
	if (current.cutsceneString != null && current.cutsceneString.Length > 1) vars.lastCutscene = current.cutsceneString;

	if (settings["cpCount"])
    {
		if (current.checkPointString != old.checkPointString)
        {
			vars.checkpointCount++;
		}
		vars.SetTextComponent("CP Counter: ", vars.checkpointCount.ToString());
	}

	int[] array = vars.avgTimePassed.ToArray();
	int sum = array.Sum();
    double average = array.Length > 0 ? sum / array.Length : double.NaN;

    if (settings["debugTextComponents"])
	{
		vars.SetTextComponent("--------------DEBUG--------------", "");
		vars.SetTextComponent("Level:", current.levelString);
		vars.SetTextComponent("Checkpoint:", current.checkPointString);
		vars.SetTextComponent("Loading:", current.isLoading.ToString());
		vars.SetTextComponent("Cutscene:", vars.lastCutscene);
		vars.SetTextComponent("Skippable:", current.skippable.ToString());
		vars.SetTextComponent("CS Timer:", vars.delayTimer.ToString());
		vars.SetTextComponent("Time Passed:", vars.timePassed.ToString()); // Debug value, will remove in the future.
		vars.SetTextComponent("Avg Time Passed:", average.ToString()); // Debug value, will remove in the future.
	}
}

reset
{
	// Reset in Wake-up Call
	if ((current.checkPointString == "Awakening_Start" && old.checkPointString != "Awakening_Start") || 
		(current.checkPointString == "Awakening_Start" && current.isLoading && !old.isLoading))
		return true;

	if (settings["levelReset"])
	{
		if (current.checkPointString == "Gate" && old.checkPointString == "Gate")
			current.snowGlobeGate = 1;

		if (current.checkPointString == "Tree_Approach_LevelIntro" && old.checkPointString != "Tree_Approach_LevelIntro" && 
			old.checkPointString != "Stargazing_Meet" && old.checkPointString != "Main Menu")
			return true;

		if (current.checkPointString == "PillowFort" && old.checkPointString != "PillowFort" && 
			old.checkPointString != "RealWorld_Exterior_Roof_Crash" && old.checkPointString != "Main Menu")
			return true;

		if (current.checkPointString == "ClockworkIntro" && old.checkPointString != "ClockworkIntro" && 
			old.checkPointString != "TherapyRoom_Time_Session" && old.checkPointString != "Main Menu")
			return true;

		if (current.checkPointString == "Forest Entry" && old.checkPointString != "Forest Entry" && 
			old.checkPointString != "TherapyRoom_Attraction_Session" && current.snowGlobeGate == 1 && old.checkPointString != "Main Menu")
		{
			current.snowGlobeGate = 0;
			return true;
		}

		if (current.checkPointString == "Intro" && old.checkPointString != "Intro" && old.checkPointString != "TherapyRoom_Garden_Session" && 
			current.levelString.ToString() == "/Game/Maps/Garden/VegetablePatch/Garden_VegetablePatch_BP" && old.checkPointString != "Main Menu")
			return true;

		if (current.checkPointString == "ConcertHall_Backstage" && old.checkPointString != "ConcertHall_Backstage" && old.checkPointString != "TherapyRoom_Music" && 
			old.checkPointString != "Main Menu" || (current.checkPointString == "ConcertHall_Backstage" && current.isLoading && !old.isLoading))
			return true;
	}

	if (settings["commGold"])
	{
		// Reset the timer in Biting the Dust
		if ((current.checkPointString == "VacuumIntro" && old.checkPointString != "VacuumIntro") || 
			(current.checkPointString == "VacuumIntro" && current.isLoading && !old.isLoading))
			return true;

		// Reset the timer in The Depths
		if ((current.checkPointString == "MineIntro" && old.checkPointString != "MineIntro") || 
			(current.checkPointString == "MineIntro" && current.isLoading && !old.isLoading))
			return true;

		// Reset the timer in Wired Up
		if ((current.checkPointString == "GrindSection_Start" && old.checkPointString != "GrindSection_Start") || 
			(current.checkPointString == "GrindSection_Start" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Fresh Air
		if ((current.checkPointString == "Tree_Approach_LevelIntro" && old.checkPointString != "Tree_Approach_LevelIntro") || 
			(current.checkPointString == "Tree_Approach_LevelIntro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Captured + Deeply Rooted + Beneath the Ice
		if ((current.checkPointString == "Entry" && old.checkPointString != "Entry") || 
			(current.checkPointString == "Entry" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Extermination
		if ((current.checkPointString == "StartWaspBossPhase1" && old.checkPointString != "StartWaspBossPhase1") || 
			(current.checkPointString == "StartWaspBossPhase1" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Getaway + Hopscotch + Green Fingers + Frog Pond
		if ((current.checkPointString == "Intro" && old.checkPointString != "Intro") || 
			(current.checkPointString == "Intro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Pillow Fort
		if ((current.checkPointString == "PillowFort" && old.checkPointString != "PillowFort") || 
			(current.checkPointString == "PillowFort" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Spaced Out
		if ((current.checkPointString == "SpaceStationIntro" && old.checkPointString != "SpaceStationIntro") || 
			(current.checkPointString == "SpaceStationIntro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Train Station
		if ((current.checkPointString == "Trainstation_Start" && old.checkPointString != "Trainstation_Start") || 
			(current.checkPointString == "Trainstation_Start" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Dino Land
		if ((current.checkPointString == "Dinoland_Start" && old.checkPointString != "Dinoland_Start") || 
			(current.checkPointString == "Dinoland_Start" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Pirates Ahoy
		if ((current.checkPointString == "Pirate_Part01_Start" && old.checkPointString != "Pirate_Part01_Start") || 
			(current.checkPointString == "Pirate_Part01_Start" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in The Greatest Show
		if ((current.checkPointString == "Circus_Start" && old.checkPointString != "Circus_Start") || 
			(current.checkPointString == "Circus_Start" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Once Upon A Time
		if ((current.checkPointString == "Castle_Courtyard_Start" && old.checkPointString != "Castle_Courtyard_Start") || 
			(current.checkPointString == "Castle_Courtyard_Start" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Dungeon Crawler
		if ((current.checkPointString == "Castle_Dungeon" && old.checkPointString != "Castle_Dungeon") || 
			(current.checkPointString == "Castle_Dungeon" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in The Queen
		if ((current.checkPointString == "Shelf_Cutie_Intro" && old.checkPointString != "Shelf_Cutie_Intro1") || 
			(current.checkPointString == "Shelf_Cutie_Intro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Gates of Time
		if ((current.checkPointString == "ClockworkIntro" && old.checkPointString != "ClockworkIntro") || 
			(current.checkPointString == "ClockworkIntro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Clockworks
		if ((current.checkPointString == "Crusher Trap Room" && old.checkPointString != "Crusher Trap Room1") || 
			(current.checkPointString == "Crusher Trap Room" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in A Blast from the Past
		if ((current.checkPointString == "Boss Intro" && old.checkPointString != "Boss Intro") || 
			(current.checkPointString == "Boss Intro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Warming Up
		if ((current.checkPointString == "Forest Entry" && old.checkPointString != "Forest Entry") || 
			(current.checkPointString == "Forest Entry" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Winter Village
		if ((current.checkPointString == "Town Entry" && old.checkPointString != "Town Entry") || 
			(current.checkPointString == "Town Entry" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Wake-Up Call
		if ((current.checkPointString == "0. Entry" && old.checkPointString != "0. Entry") || 
			(current.checkPointString == "0. Entry" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Weed Whacking
		if ((current.checkPointString == "Shrubbery_Enter" && old.checkPointString != "Shrubbery_Enter") || 
			(current.checkPointString == "Shrubbery_Enter" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Trespassing
		if ((current.checkPointString == "MoleTunnels_Level_Intro" && old.checkPointString != "MoleTunnels_Level_Intro") || 
			(current.checkPointString == "MoleTunnels_Level_Intro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Affliction
		if ((current.checkPointString == "Greenhouse_Intro" && old.checkPointString != "Greenhouse_Intro") || 
			(current.checkPointString == "Greenhouse_Intro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Setting the Stage
		if ((current.checkPointString == "ConcertHall_Backstage" && old.checkPointString != "ConcertHall_Backstage") || 
			(current.checkPointString == "ConcertHall_Backstage" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Rehearsal
		if ((current.checkPointString == "Tutorial_Intro" && old.checkPointString != "Tutorial_Intro") || 
			(current.checkPointString == "Tutorial_Intro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Symphony
		if ((current.checkPointString == "Classic_01_Attic_Intro" && old.checkPointString != "Classic_01_Attic_Intro") || 
			(current.checkPointString == "Classic_01_Attic_Intro" && current.isLoading && !old.isLoading)) 
			return true;

		// Reset the timer in Turn Up
		if ((current.checkPointString == "RainbowSlide" && old.checkPointString != "RainbowSlide") || 
			(current.checkPointString == "RainbowSlide" && current.isLoading && !old.isLoading))
			return true;

		// Reset the timer in A Grand Finale
		if ((current.checkPointString == "EndingIntro" && old.checkPointString != "EndingIntro") || 
			(current.checkPointString == "EndingIntro" && current.isLoading && !old.isLoading)) 
			return true;
	}
}

start
{
	current.cutsceneCount = 0; // Reset cutscene counter
	vars.checkpointCount = 0;
	vars.avgTimePassed.Clear();
	vars.iceCaveDone = 0;
	vars.splitNextLoad = false;

	vars.startLevels = new List<string>()
	{
		"/Game/Maps/Shed/Awakening/Awakening_BP",
		"/Game/Maps/Tree/Approach/Approach_BP",
		"/Game/Maps/PlayRoom/PillowFort/PillowFort_BP",
		"/Game/Maps/Clockwork/Outside/Clockwork_Tutorial_BP",
		"/Game/Maps/SnowGlobe/Forest/SnowGlobe_Forest_BP",
		"/Game/Maps/Garden/VegetablePatch/Garden_VegetablePatch_BP",
		"/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP"
	};

	vars.commStartLevels = new List<string>()
	{
		"/Game/Maps/Shed/Vacuum/Vacuum_BP",
		"/Game/Maps/Shed/Main/Main_Hammernails_BP",
		"/Game/Maps/Shed/Main/Main_Grindsection_BP",
		"/Game/Maps/Tree/SquirrelHome/SquirrelHome_BP_Mech",
		"/Game/Maps/Tree/WaspNest/WaspsNest_BP",
		"/Game/Maps/Tree/Boss/WaspQueenBoss_BP",
		"/Game/Maps/Tree/Escape/Escape_BP",
		"/Game/Maps/PlayRoom/Spacestation/Spacestation_Hub_BP",
		"/Game/Maps/PlayRoom/Hopscotch/Hopscotch_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Trainstation_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Dinoland_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Pirate_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Circus_BP",
		"/Game/Maps/PlayRoom/Courtyard/Castle_Courtyard_BP",
		"/Game/Maps/PlayRoom/Dungeon/Castle_Dungeon_BP",
		"/Game/Maps/PlayRoom/Shelf/Shelf_BP",
		"/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_CrushingTrapRoom_BP",
		"/Game/Maps/Clockwork/UpperTower/Clockwork_ClockTowerLastBoss_BP",
		"/Game/Maps/SnowGlobe/Town/SnowGlobe_Town_BP",
		"/Game/Maps/SnowGlobe/Lake/Snowglobe_Lake_BP",
		"/Game/Maps/SnowGlobe/Mountain/SnowGlobe_Mountain_BP",
		"/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_BP",
		"/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Stealth_BP",
		"/Game/Maps/Garden/FrogPond/Garden_FrogPond_BP",
		"/Game/Maps/Garden/Greenhouse/Garden_Greenhouse_BP",
		"/Game/Maps/Music/Backstage/Music_Backstage_Tutorial_BP",
		"/Game/Maps/Music/Classic/Music_Classic_Organ_BP",
		"/Game/Maps/Music/Nightclub/Music_Nightclub_BP",
		"/Game/Maps/Music/Ending/Music_Ending_BP"
	};

	if (current.isLoading)
    {
		if (vars.startLevels.Contains(current.levelString))
			return true;

		if (settings["commGold"] && vars.commStartLevels.Contains(current.levelString))
			return true;
	}
}

split
{
	// Intermediaries (Deprecated)
	if (settings["intermediaries"])
    {
		// Intermediary 1
		if (current.levelString == "/Game/Maps/Tree/Approach/Approach_BP" && old.levelString == "/Game/Maps/RealWorld/RealWorld_Shed_StarGazing_Meet_BP")
			return true;

		// Intermediary 2
		if (current.levelString == "/Game/Maps/PlayRoom/PillowFort/PillowFort_BP" && old.levelString == "/Game/Maps/RealWorld/RealWorld_Exterior_Roof_Crash_BP")
			return true;

		// Intermediary 3
		if (current.levelString == "/Game/Maps/Clockwork/Outside/Clockwork_Tutorial_BP" && old.levelString == "/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Time_BP")
			return true;

		// Intermediary 4
		if (current.levelString == "/Game/Maps/SnowGlobe/Forest/SnowGlobe_Forest_BP" && old.levelString == "/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Attraction_BP")
			return true;

		// Intermediary 5
		if (current.levelString == "/Game/Maps/Garden/VegetablePatch/Garden_VegetablePatch_BP" && old.levelString == "/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Garden_BP")
			return true;

		// Intermediary 6
		if (current.levelString == "/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP" && old.levelString == "/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Music_BP")
			return true;
	}




	//The Shed
	// Wake-Up Call to Biting the Dust
	if (current.levelString == "/Game/Maps/Shed/Vacuum/Vacuum_BP" && old.levelString == "/Game/Maps/Shed/Awakening/Awakening_BP") 
		return true;

	// Biting The Dust to The Depths
	if (current.levelString == "/Game/Maps/Shed/Main/Main_Hammernails_BP" && old.levelString == "/Game/Maps/Shed/Vacuum/Vacuum_BP") 
		return true;

	// The Depths to Wired Up
	if (current.levelString == "/Game/Maps/Shed/Main/Main_Grindsection_BP" && 
		(old.levelString == "/Game/Maps/Shed/Main/Main_Hammernails_BP" || old.levelString == "/Game/Maps/Shed/Main/Main_Bossfight_BP"))
		return true;

	// Wired Up to Fresh Air
	if (current.levelString == "/Game/Maps/RealWorld/RealWorld_Shed_StarGazing_Meet_BP" && old.levelString == "/Game/Maps/Shed/Main/Main_Grindsection_BP") 
		return true;



	//The Tree
	// Fresh Air to Captured
	if (current.levelString == "/Game/Maps/Tree/SquirrelHome/SquirrelHome_BP_Mech" && old.levelString == "/Game/Maps/Tree/SquirreTurf/SquirrelTurf_WarRoom_BP") 
		return true;

	// Captured to Deeply Rooted
	if (current.levelString == "/Game/Maps/Tree/WaspNest/WaspsNest_BP" && old.levelString == "/Game/Maps/Tree/SquirrelHome/SquirrelHome_BP_Mech") 
		return true;

	// Deeply Rooted to Extermination
	if (current.levelString == "/Game/Maps/Tree/Boss/WaspQueenBoss_BP" && old.levelString == "/Game/Maps/Tree/WaspNest/WaspsNest_BeetleRide_BP") 
		return true;

	// Extermination to Getaway
	if (current.levelString == "/Game/Maps/Tree/Escape/Escape_BP" && old.levelString == "/Game/Maps/Tree/SquirreTurf/SquirrelTurf_Flight_BP") 
		return true;

	// Getaway to Pillow Fort
	if (current.checkPointString == "Glider halfway through" && vars.lastCutscene == "CS_RealWorld_House_LivingRoom_Headache" && vars.lastCutsceneOld == "null")
		return true;

	/* // OLD SPLIT CONDITION
	if(current.checkPointString == "Glider halfway through" && current.isCutscene && !old.isCutscene)
		return true;*/



	//Rose's Room
	// Pillow Fort to Spaced Out
	if (current.levelString == "/Game/Maps/PlayRoom/Spacestation/Spacestation_Hub_BP" && old.levelString == "/Game/Maps/PlayRoom/PillowFort/PillowFort_BP") 
		return true;

	// Spaced Out to Hopscotch
	if (current.levelString == "/Game/Maps/PlayRoom/Hopscotch/Hopscotch_BP" && old.levelString == "/Game/Maps/RealWorld/Realworld_SpaceStation_Bossfight_BeamOut_BP") 
		return true;

	// Hopscotch to Train Station
	if (current.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Trainstation_BP" && old.levelString == "/Game/Maps/PlayRoom/Hopscotch/Kaleidoscope_BP") 
		return true;

	// Train Station to Dino Land
	if (current.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Dinoland_BP" && vars.lastCutsceneOld == "CS_PlayRoom_DinoLand_DinoCrash_Intro" && vars.lastCutscene == "null") 
		return true;

	// Dino Land to Pirates Ahoy
	if (current.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Pirate_BP" && old.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Dinoland_BP") 
		return true;

	// Pirates Ahoy to The Greatest Show
	if (current.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Circus_BP" && vars.lastCutsceneOld == "CS_PlayRoom_Circus_Balloon_Intro" && vars.lastCutscene == "null") 
		return true;

	// The Greatest Show to Once Upon a Time
	if (current.levelString == "/Game/Maps/PlayRoom/Courtyard/Castle_Courtyard_BP" && old.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Circus_BP") 
		return true;

	// Once Upon a Time to Dungeon Crawler
	if (current.levelString == "/Game/Maps/PlayRoom/Dungeon/Castle_Dungeon_BP" && old.levelString == "/Game/Maps/PlayRoom/Courtyard/Castle_Courtyard_BP") 
		return true;

	// Dungeon Crawler to The Queen
	if (current.levelString == "/Game/Maps/PlayRoom/Shelf/Shelf_BP" && old.levelString == "/Game/Maps/PlayRoom/Chessboard/Castle_Chessboard_BP") 
		return true;

	// The Queen to Gates of Time
	if (current.levelString == "/Game/Maps/RealWorld/RealWorld_RoseRoom_Bed_Tears_BP" && old.levelString == "/Game/Maps/PlayRoom/Shelf/Shelf_BP") 
		return true;



	//Cuckoo Clock
	// Gates of Time to Clockworks
	if (current.levelString == "/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_CrushingTrapRoom_BP" && 
		(old.levelString == "/Game/Maps/Clockwork/Outside/Clockwork_ClockTowerCourtyard_BP" || 
		old.levelString == "/Game/Maps/Clockwork/Outside/Clockwork_Forest_BP")) 
		return true;

	// Clockworks to A Blast from the Past
	if (current.levelString == "/Game/Maps/Clockwork/UpperTower/Clockwork_ClockTowerLastBoss_BP" && 
		(old.levelString == "/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_CuckooBirdRoom_BP" || 
		old.levelString == "/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_EvilBirdRoom_BP")) 
		return true;

	// A Blast from the Past to Warming Up
	if (current.checkPointString == "Sprint To Couple" && vars.lastCutscene == "CS_ClockWork_UpperTower_EndingRewind" && vars.lastCutsceneOld == "null")
		return true;

	/* // OLD SPLIT CONDITION
	if (current.checkPointString == "Sprint To Couple" && current.isCutscene && !old.isCutscene)
		return true;*/



	//Snow Globe
	// Warming Up to Winter Village
	if (current.levelString == "/Game/Maps/SnowGlobe/Town/SnowGlobe_Town_BP" && (old.levelString == "/Game/Maps/SnowGlobe/Forest/SnowGlobe_Forest_BP" || 
		old.levelString == "/Game/Maps/SnowGlobe/Forest/SnowGlobe_Forest_TownGate_BP")) 
		return true;

	// Winter Village to Beneath the Ice
	if (current.levelString == "/Game/Maps/SnowGlobe/Lake/Snowglobe_Lake_BP" && old.levelString == "/Game/Maps/SnowGlobe/Town/SnowGlobe_Town_BobSled") 
		return true;

	// Beneath the Ice to Slippery Slopes
	if (current.levelString == "/Game/Maps/SnowGlobe/Mountain/SnowGlobe_Mountain_BP" && old.levelString == "/Game/Maps/SnowGlobe/Lake/Snowglobe_Lake_BP") 
		return true;

	// Slippery Slopes to Green Fingers
	if (current.checkPointString == "TerraceProposalCutscene" && old.checkPointString != "TerraceProposalCutscene")
		return true;



	//Garden
	// Green Fingers to Weed Whacking
	if (current.levelString == "/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_BP" && old.levelString == "/Game/Maps/Garden/VegetablePatch/Garden_VegetablePatch_BP") 
		return true;

	// Weed Whacking to Trespassing
	if (current.levelString == "/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Stealth_BP" && 
		(old.levelString == "/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_SecondCombat_BP" || old.levelString == "/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_BP")) 
		return true;

	// Trespassing to Frog Pond
	if (current.levelString == "/Game/Maps/Garden/FrogPond/Garden_FrogPond_BP" && 
		(old.levelString == "/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Chase_BP" || old.levelString == "/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Stealth_BP")) 
		return true;

	// Frog Pond to Affliction
	if (current.levelString == "/Game/Maps/Garden/Greenhouse/Garden_Greenhouse_BP" && old.levelString == "/Game/Maps/Garden/FrogPond/Garden_FrogPond_BP") 
		return true;

	// Affliction to Setting the Stage
	if (vars.lastCutscene == "CS_Garden_GreenHouse_BossRoom_Outro" && vars.lastCutsceneOld == "null" && current.checkPointString == "Joy_Bossfight_Phase_3_Combat")
		return true;

	/* // OLD SPLIT CONDITION
	if(current.checkPointString == "Joy_Bossfight_Phase_3_Combat")
	{
		if(old.checkPointString != "Joy_Bossfight_Phase_3_Combat")
			current.cutsceneCount = 0;
		if(current.isLoading && !old.isLoading)
			current.cutsceneCount = 1;
		if(current.isCutscene && !old.isCutscene)
    		{
        		current.cutsceneCount++;
        		if(current.cutsceneCount == 3)
            			return true;
    		}
	}*/



	//The Attic
	// Setting the Stage / Symphony to Turn Up
	if (current.levelString == "/Game/Maps/Music/Nightclub/Music_Nightclub_BP" && old.levelString == "/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP") 
		return true;

	// Setting the Stage to Rehearsal (Inbounds/OOB Only)
	if (current.levelString == "/Game/Maps/Music/Backstage/Music_Backstage_Tutorial_BP" && old.levelString == "/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP") 
		return true;

	// Rehearsal to Symphony (Inbounds/OOB Only)
	if (current.levelString == "/Game/Maps/Music/Classic/Music_Classic_Organ_BP" && old.levelString == "/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP") 
		return true;

	// Turn up to A Grand Finale
	if (current.levelString == "/Game/Maps/Music/Ending/Music_Ending_BP" && old.levelString == "/Game/Maps/Music/Nightclub/Music_Nightclub_BP") 
		return true;

	// Ending
	if (vars.lastCutscene == "CS_Music_Attic_Stage_ClimacticKiss" && vars.lastCutsceneOld == "CT_Music_Ending_Smooch")
		return true;

    /* // OLD SPLIT CONDITION
	if(current.checkPointString == "MayInDressingRoom")
	{
		if(old.checkPointString != "MayInDressingRoom")
			current.cutsceneCount = 0;
		if(current.isCutscene && !old.isCutscene) // Count cutscenes in A Grand Finale to end timer after kiss
    		{
        		current.cutsceneCount++;
        		if(current.cutsceneCount == 2)
            			return true;
        }
    }*/

    if (settings["optionalSplits"])
    {
        // Split on next load
        if (vars.splitNextLoad && current.isLoading && !old.isLoading)
        {
            vars.splitNextLoad = false;
            return true;
        }


        // Biting the Dust
        // Vacuum Battle
        if (settings["vacuumBattle"] && vars.lastCutscene == "CS_Shed_Awakening_Vacuum_Battle" && vars.lastCutsceneOld == "null")
        {
            return true;
        }


        // The Depths
        // Pre Boss Double Interact
        if (settings["preBossDoubleInteract"] && old.checkPointString != current.checkPointString && current.checkPointString == "Pre Boss Double Interact")
        {
            vars.splitNextLoad = true;
        }


        // Captured
        // Minigame Tug of War
        if (settings["tug"] && old.checkPointString != current.checkPointString && current.checkPointString == "MINIGAME_TugOfWar")
        {
            return true;
        }


        // Deeply Rooted
        // Boat Start
        if (settings["boatStart"] && old.levelString == "/Game/Maps/Tree/WaspNest/WaspsNest_BP" && current.levelString == "/Game/Maps/Tree/Boat/Tree_Boat_BP")
        {
            vars.splitNextLoad = true;
        }

        // Boat Swarm
        if (settings["boatSwarm"] && old.checkPointString != current.checkPointString && current.checkPointString == "Boat Checkpoint Swarm")
        {
            vars.splitNextLoad = true;
        }

        // DarkRoom Start
        if (settings["darkroomStart"] && old.levelString == "/Game/Maps/Tree/Boat/Tree_Boat_BP" && current.levelString == "/Game/Maps/Tree/Darkroom/Tree_Darkroom_BP")
        {
            return true;
        }

        // Second Lantern
        if (settings["secondLantern"] && old.checkPointString != current.checkPointString && current.checkPointString == "SecondLantern")
        {
            return true;
        }

        // Third Lantern
        if (settings["thirdLantern"] && old.checkPointString != current.checkPointString && current.checkPointString == "ThirdLantern")
        {
            return true;
        }

        // Beetle Elevator
        if (settings["beetleElevator"] && old.levelString == "/Game/Maps/Tree/Darkroom/Tree_Darkroom_BP" &&
            current.levelString == "/Game/Maps/Tree/WaspNest/WaspsNest_Elevator_BP")
        {
            return true;
        }

        // Beetle Arena
        if (settings["beetleArena"] && vars.lastCutscene == "CS_Tree_WaspNest_Arena_Intro" && vars.lastCutsceneOld == "null")
        {
            return true;
        }


        // Extermination
        // Plane Intro
        if (settings["planeIntro"] && vars.lastCutscene == "CS_Tree_WaspQueenBoss_Arena_PlaneIntro" && vars.lastCutsceneOld == "null")
        {
            return true;
        }

        // Smash in Wood
        if (settings["smashWood"] && vars.lastCutscene == "CS_Tree_WaspQueenBoss_Arena_SmashInWood" && vars.lastCutsceneOld == "null")
        {
            return true;
        }


        // Getaway
        // Glider Halfway through
        if (settings["gliderHalfway"] && old.checkPointString != current.checkPointString && current.checkPointString == "Glider halfway through")
        {
            return true;
        }


        // Spaced Out
        // First Portal Platform
        if (settings["firstPlatform"] && old.checkPointString != current.checkPointString && current.checkPointString == "FirstPortalPlatform")
        {
            return true;
        }

        // UFO Eject Button
        if (settings["eject"] && vars.lastCutscene == "CS_PlayRoom_SpaceStation_BossFight_Eject" && vars.lastCutsceneOld == "null")
        {
            return true;
        }


        // Hopscotch
        // Grind Section
        if (settings["grind"] && old.checkPointString != current.checkPointString && current.checkPointString == "Grind Section")
        {
            return true;
        }

        // Void World
        if (settings["void"] && old.levelString == "/Game/Maps/PlayRoom/Hopscotch/Hopscotch_BP" && current.levelString == "/Game/Maps/PlayRoom/Hopscotch/VoidWorld_BP")
        {
            return true;
        }

        // Kaleidoscope
        if (settings["kaleidoscope"] && old.levelString == "/Game/Maps/PlayRoom/Hopscotch/VoidWorld_BP" && current.levelString == "/Game/Maps/PlayRoom/Hopscotch/Kaleidoscope_BP")
        {
            return true;
        }


        // Dino Land
        // Pteranodon
        if (settings["pteranodon"] && vars.lastCutscene == "EV_PlayRoom_DinoLand_PteranodonCrash" && vars.lastCutsceneOld == "null")
        {
            return true;
        }


        // Pirates Ahoy
        // Ships Intro
        if (settings["ships"] && vars.lastCutscene == "CS_Playroom_Goldberg_Pirate_ShipsIntro" && vars.lastCutsceneOld == "null")
        {
            return true;
        }

        // Boss Start
        if (settings["pirateBoss"] && vars.lastCutscene == "CS_PlayRoom_Goldberg_Pirate_BossIntro_MainScene" && vars.lastCutsceneOld == "null")
        {
            return true;
        }


        // Greatest Show
        // Trapeeze
        if (settings["trapeeze"] && old.checkPointString != current.checkPointString && current.checkPointString == "Circus_Trapeeze")
        {
            return true;
        }


        // Once Upon a Time
        // Crane
        if (settings["crane"] && old.checkPointString != current.checkPointString && current.checkPointString == "Castle_Courtyard_CranePuzzle")
        {
            return true;
        }


        // Dungeon Crawler
        // Crusher Intro
        if (settings["crusherIntro"] && vars.lastCutscene == "CS_Playroom_Castle_Dungeon_CrusherIntro" && vars.lastCutsceneOld == "null")
        {
            return true;
        }

        // Chess
        if (settings["chess"] && old.levelString == "/Game/Maps/PlayRoom/Dungeon/Castle_Dungeon_Charger_BP" && current.levelString == "/Game/Maps/PlayRoom/Chessboard/Castle_Chessboard_BP")
        {
            return true;
        }


        // Gates of Time
        // Clocktown Intro
        if (settings["clocktown"] && vars.lastCutscene == "CS_ClockWork_Outside_ClockTown_Intro" && vars.lastCutsceneOld == "null")
        {
            return true;
        }

        // Hell Tower
        if (settings["hellTower"] && vars.lastCutscene == "LS_Clockwork_Outside_ClockTown_RevealHellTower" && vars.lastCutsceneOld == "null")
        {
            return true;
        }

        // Bird Intro
        if (settings["birdIntro"] && vars.lastCutscene == "CS_ClockWork_Outside_Bird_Intro" && vars.lastCutsceneOld == "null")
        {
            return true;
        }

        // Right Tower Destroyed
        if (settings["rightTowerDestroyed"] && old.checkPointString != current.checkPointString && current.checkPointString == "Right Tower Destroyed")
        {
            vars.splitNextLoad = true;
        }


        // Clockworks
        // Statue Room
        if (settings["statue"] && old.checkPointString != current.checkPointString && current.checkPointString == "Statue Room")
        {
            vars.splitNextLoad = true;
        }

        // Wall Jump Corridor
        if (settings["wallJump"] && old.checkPointString != current.checkPointString && current.checkPointString == "Wall Jump Corridor")
        {
            vars.splitNextLoad = true;
        }

        // Pocket Watch Room
        if (settings["pocketWatch"] && old.checkPointString != current.checkPointString && current.checkPointString == "Pocket Watch Room")
        {
            vars.splitNextLoad = true;
        }


        // A Blast from the Past
        // After Rewind Smash
        if (settings["afterRewindSmash"] && vars.lastCutscene == "CS_Clockwork_UpperTower_LastBoss_AfterRewindSmash" && vars.lastCutsceneOld == "null")
        {
            return true;
        }


        // Beneath the Ice
        // Ice Cave Done
        if (vars.iceCaveDone == 0 && old.checkPointString != current.checkPointString && current.checkPointString == "CoreBase")
        {
            vars.iceCaveDone = 1;
            if (settings["iceCave"])
            {
                vars.splitNextLoad = true;
            }
        }

        // Fish Done
        if (settings["fish"] && vars.iceCaveDone == 1 && current.checkPointString == "CoreBase" && old.isLoading && !current.isLoading)
        {
            vars.iceCaveDone = 2;
            vars.splitNextLoad = true;
        }


        // Slippery Slopes
        // Collapse
        if (settings["collapse"] && old.checkPointString != current.checkPointString && current.checkPointString == "3. Collapse")
        {
            vars.splitNextLoad = true;
        }

        // Player Attraction
        if (settings["playerAttraction"] && old.checkPointString != current.checkPointString && current.checkPointString == "4. PlayerAttraction")
        {
            vars.splitNextLoad = true;
        }


        // Green Fingers
        // Cactus
        if (settings["cactus"] && old.checkPointString != current.checkPointString && current.checkPointString == "Cactus Combat Area")
        {
            return true;
        }

        // Beanstalk
        if (settings["beanstalk"] && old.checkPointString != current.checkPointString && current.checkPointString == "Beanstalk Section")
        {
            return true;
        }

        // Burrown
        if (settings["burrown"] && old.checkPointString != current.checkPointString && current.checkPointString == "Burrown Enemy")
        {
            return true;
        }

        // Greenhouse Window
        if (settings["window"] && old.checkPointString != current.checkPointString && current.checkPointString == "Greenhouse Window")
        {
            return true;
        }


        // Weed Whacking
        // Starting Final Combat
        if (settings["finalCombat"] && old.checkPointString != current.checkPointString && current.checkPointString == "Shrubbery_StartingFinalCombat")
        {
            vars.splitNextLoad = true;
        }

        // Final Combat Second Wave
        if (settings["cactusWaves"] && vars.lastCutscene == "CS_Garden_Shrubbery_CactusWaves_Intro" && vars.lastCutsceneOld == "null")
        {
            return true;
        }


        // Trespassing
        // Gnome RCP
        if (settings["gnome"] && old.checkPointString != current.checkPointString && current.checkPointString == "MoleTunnels_MoleChase_2D_TreasureRoom")
        {
            return true;
        }


        // Frog Pond
        // Minigame Snail Race
        if (settings["snail"] && old.checkPointString != current.checkPointString && current.checkPointString == "Minigame_SnailRace")
        {
            return true;
        }


        // Affliction
        // Joy Intro
        if (settings["joyIntro"] && vars.lastCutscene == "null" && vars.lastCutsceneOld == "CS_Garden_GreenHouse_BossRoom_Intro")
        {
            return true;
        }

        // Joy Phase 2
        if (settings["joyPhase2"] && old.checkPointString != current.checkPointString && current.checkPointString == "Joy_Bossfight_Phase_2")
        {
            return true;
        }

        // Joy Phase 3
        if (settings["joyPhase3"] && old.checkPointString != current.checkPointString && current.checkPointString == "Joy_Bossfight_Phase_3")
        {
            return true;
        }


        // Setting the Stage
        // Track Runner
        if (settings["trackRunner"] && old.checkPointString != current.checkPointString && current.checkPointString == "MINIGAME_TrackRunner")
        {
            return true;
        }


        // Turn Up
        // DJ Elevator
        if (settings["djElevator"] && vars.lastCutscene == "CS_Music_NightClub_Basement_Elevator" && vars.lastCutsceneOld == "CT_Music_Nightclub_Basement_DjElevator")
        {
            return true;
        }

		// Audio Surf
		if (settings["audioSurf"] && old.checkPointString != current.checkPointString && current.checkPointString == "AudioSurf")
        {
			return true;
        }
    }
}
