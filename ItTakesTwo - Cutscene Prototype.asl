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
	//settings.Add("commGold", false, "Comm Gold Resets");
	//settings.Add("levelReset", false, "IL Resets");

	// DEBUG
	settings.Add("debugTextComponents", false, "[DEBUG] Show tracked values in layout");

}

init
{
    int cutsceneCount = 0; // Initialize cutscene counter
	vars.delayTimer = 0;
	vars.delayTimerTimestamp = 0;
	vars.lastCutscene = "";
	vars.lastCutsceneOld = "";

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
}

isLoading
{
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
		if (current.skippable <= 0 && old.skippable >= 1)
        {
			vars.delayTimer = 0;
        }
		else
		{
			vars.delayTimer = adjustment;
			return true;
		}
	}

	if ((current.skippable >= 1 && old.skippable <= 0) || (vars.lastCutsceneOld != vars.lastCutscene && current.skippable >= 1)) 
	{ 
		vars.delayTimer = 5000; // How long to delay loads during skippable cutscenes
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

	if (settings["debugTextComponents"])
	{
		vars.SetTextComponent("--------------DEBUG--------------", "");
		vars.SetTextComponent("Level:", current.levelString);
		vars.SetTextComponent("Checkpoint:", current.checkPointString);
		vars.SetTextComponent("Loading:", current.isLoading.ToString());
		vars.SetTextComponent("Cutscene:", vars.lastCutscene);
		vars.SetTextComponent("Skippable:", current.skippable.ToString());
		vars.SetTextComponent("CS Timer:", vars.delayTimer.ToString());
	}
}

reset
{
	if(current.checkPointString == "Awakening_Start" && old.checkPointString != "Awakening_Start")
		return true;
}

start
{
	current.cutsceneCount = 0; // Reset cutscene counter

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
	//The Shed
	if(current.levelString == "/Game/Maps/Shed/Vacuum/Vacuum_BP" && old.levelString == "/Game/Maps/Shed/Awakening/Awakening_BP") // Wake-Up Call to Biting the Dust
		return true;
	if(current.levelString == "/Game/Maps/Shed/Main/Main_Hammernails_BP" && old.levelString == "/Game/Maps/Shed/Vacuum/Vacuum_BP") // Biting The Dust to The Depths
		return true;
	if(current.levelString == "/Game/Maps/Shed/Main/Main_Grindsection_BP" && old.levelString == "/Game/Maps/Shed/Main/Main_Hammernails_BP") // The Depths to Wired Up (0 cycle)
		return true;
	if(current.levelString == "/Game/Maps/Shed/Main/Main_Grindsection_BP" && old.levelString == "/Game/Maps/Shed/Main/Main_Bossfight_BP") // The Depths to Wired Up (2 cycle)
		return true;
	if(current.levelString == "/Game/Maps/RealWorld/RealWorld_Shed_StarGazing_Meet_BP" && old.levelString == "/Game/Maps/Shed/Main/Main_Grindsection_BP") // Wired Up to Fresh Air
		return true;

	if(current.levelString == "/Game/Maps/Tree/Approach/Approach_BP" && old.levelString == "/Game/Maps/RealWorld/RealWorld_Shed_StarGazing_Meet_BP") // Intermediary 1
		return true;

	//The Tree
	if(current.levelString == "/Game/Maps/Tree/SquirrelHome/SquirrelHome_BP_Mech" && old.levelString == "/Game/Maps/Tree/SquirreTurf/SquirrelTurf_WarRoom_BP") // Fresh Air to Captured
		return true;
	if(current.levelString == "/Game/Maps/Tree/WaspNest/WaspsNest_BP" && old.levelString == "/Game/Maps/Tree/SquirrelHome/SquirrelHome_BP_Mech") // Captured to Deeply Rooted
		return true;
	if(current.levelString == "/Game/Maps/Tree/Boss/WaspQueenBoss_BP" && old.levelString == "/Game/Maps/Tree/WaspNest/WaspsNest_BeetleRide_BP") // Deeply Rooted to Extermination
		return true;
	if(current.levelString == "/Game/Maps/Tree/Escape/Escape_BP" && old.levelString == "/Game/Maps/Tree/SquirreTurf/SquirrelTurf_Flight_BP") // Extermination to Getaway
		return true;
	if(current.checkPointString == "Glider halfway through" && current.isCutscene && !old.isCutscene)
		return true;

	if(current.levelString == "/Game/Maps/PlayRoom/PillowFort/PillowFort_BP" && old.levelString == "/Game/Maps/RealWorld/RealWorld_Exterior_Roof_Crash_BP") // Intermediary 2
		return true;

	//Rose's Room
	if(current.levelString == "/Game/Maps/PlayRoom/Spacestation/Spacestation_Hub_BP" && old.levelString == "/Game/Maps/PlayRoom/PillowFort/PillowFort_BP") // Pillow Fort to Spaced Out
		return true;
	if(current.levelString == "/Game/Maps/PlayRoom/Hopscotch/Hopscotch_BP" && old.levelString == "/Game/Maps/RealWorld/Realworld_SpaceStation_Bossfight_BeamOut_BP") // Spaced Out to Hopscotch
		return true;
	if(current.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Trainstation_BP" && old.levelString == "/Game/Maps/PlayRoom/Hopscotch/Kaleidoscope_BP") // Hopscotch to Train Station
		return true;
	if(current.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Dinoland_BP" && old.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Trainstation_BP") // Train Station to Dino Land
		return true;
	if(current.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Pirate_BP" && old.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Dinoland_BP") // Dino Land to Pirates Ahoy
		return true;
	if(current.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Circus_BP" && old.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Pirate_BP") // Pirates Ahoy to The Greatest Show
		return true;
	if(current.levelString == "/Game/Maps/PlayRoom/Courtyard/Castle_Courtyard_BP" && old.levelString == "/Game/Maps/PlayRoom/Goldberg/Goldberg_Circus_BP") // The Greatest Show to Once Upon a Time
		return true;
	if(current.levelString == "/Game/Maps/PlayRoom/Dungeon/Castle_Dungeon_BP" && old.levelString == "/Game/Maps/PlayRoom/Courtyard/Castle_Courtyard_BP") // Once Upon a Time to Dungeon Crawler
		return true;
	if(current.levelString == "/Game/Maps/PlayRoom/Shelf/Shelf_BP" && old.levelString == "/Game/Maps/PlayRoom/Chessboard/Castle_Chessboard_BP") // Dungeon Crawler to The Queen
		return true;
	if(current.levelString == "/Game/Maps/RealWorld/RealWorld_RoseRoom_Bed_Tears_BP" && old.levelString == "/Game/Maps/PlayRoom/Shelf/Shelf_BP") // The Queen to Gates of Time
		return true;

	if(current.levelString == "/Game/Maps/Clockwork/Outside/Clockwork_Tutorial_BP" && old.levelString == "/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Time_BP") // Intermediary 3
		return true;

	//Cuckoo Clock
	if(current.levelString == "/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_CrushingTrapRoom_BP" && old.levelString == "/Game/Maps/Clockwork/Outside/Clockwork_ClockTowerCourtyard_BP") // Gates of Time to Clockworks (Restart CP)
		return true;
	if(current.levelString == "/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_CrushingTrapRoom_BP" && old.levelString == "/Game/Maps/Clockwork/Outside/Clockwork_Forest_BP") // Gates of Time to Clockworks
		return true;
	if(current.levelString == "/Game/Maps/Clockwork/UpperTower/Clockwork_ClockTowerLastBoss_BP" && old.levelString == "/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_CuckooBirdRoom_BP") // Clockworks to A Blast from the Past
		return true;
	if(current.levelString == "/Game/Maps/Clockwork/UpperTower/Clockwork_ClockTowerLastBoss_BP" && old.levelString == "/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_EvilBirdRoom_BP") // Clockworks to A Blast from the Past (Restart CP)
		return true;
	if(current.checkPointString == "Sprint To Couple" && current.isCutscene && !old.isCutscene)
		return true;

	if(current.levelString == "/Game/Maps/SnowGlobe/Forest/SnowGlobe_Forest_BP" && old.levelString == "/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Attraction_BP") // Intermediary 4
		return true;

	//Snow Globe
	if(current.levelString == "/Game/Maps/SnowGlobe/Town/SnowGlobe_Town_BP" && old.levelString == "/Game/Maps/SnowGlobe/Forest/SnowGlobe_Forest_BP") // Warming Up to Winter Village
		return true;
	if(current.levelString == "/Game/Maps/SnowGlobe/Town/SnowGlobe_Town_BP" && old.levelString == "/Game/Maps/SnowGlobe/Forest/SnowGlobe_Forest_TownGate_BP") // Warming Up to Winter Village (Restart CP)
		return true;
	if(current.levelString == "/Game/Maps/SnowGlobe/Lake/Snowglobe_Lake_BP" && old.levelString == "/Game/Maps/SnowGlobe/Town/SnowGlobe_Town_BobSled") // Winter Village to Beneath the Ice
		return true;
	if(current.levelString == "/Game/Maps/SnowGlobe/Mountain/SnowGlobe_Mountain_BP" && old.levelString == "/Game/Maps/SnowGlobe/Lake/Snowglobe_Lake_BP") // Beneath the Ice to Slippery Slopes
		return true;
	if(current.checkPointString == "TerraceProposalCutscene" && old.checkPointString != "TerraceProposalCutscene")
		return true;

	if(current.levelString == "/Game/Maps/Garden/VegetablePatch/Garden_VegetablePatch_BP" && old.levelString == "/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Garden_BP") // Intermediary 5
		return true;

	//Garden
	if(current.levelString == "/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_BP" && old.levelString == "/Game/Maps/Garden/VegetablePatch/Garden_VegetablePatch_BP") // Green Fingers to Weed Whacking
		return true;
	if(current.levelString == "/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Stealth_BP" && old.levelString == "/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_SecondCombat_BP") // Weed Whacking to Trespassing (Restart CP)
		return true;
	if(current.levelString == "/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Stealth_BP" && old.levelString == "/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_BP") // Weed Whacking to Trespassing
		return true;
	if(current.levelString == "/Game/Maps/Garden/FrogPond/Garden_FrogPond_BP" && old.levelString == "/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Chase_BP") // Trespassing to Frog Pond (Restart CP)
		return true;
	if(current.levelString == "/Game/Maps/Garden/FrogPond/Garden_FrogPond_BP" && old.levelString == "/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Stealth_BP") // Trespassing to Frog Pond
		return true;
	if(current.levelString == "/Game/Maps/Garden/Greenhouse/Garden_Greenhouse_BP" && old.levelString == "/Game/Maps/Garden/FrogPond/Garden_FrogPond_BP") // Frog Pond to Affliction
		return true;
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
	}

	if(current.levelString == "/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP" && old.levelString == "/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Music_BP") // Intermediary 6
		return true;

	//The Attic
	if(current.levelString == "/Game/Maps/Music/Nightclub/Music_Nightclub_BP" && old.levelString == "/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP") // Setting the Stage / Symphony to Turn Up
		return true;
	if(current.levelString == "/Game/Maps/Music/Backstage/Music_Backstage_Tutorial_BP" && old.levelString == "/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP") // Setting the Stage to Rehearsal (Inbounds/OOB Only)
		return true;
	if(current.levelString == "/Game/Maps/Music/Classic/Music_Classic_Organ_BP" && old.levelString == "/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP") // Rehearsal to Symphony (Inbounds/OOB Only)
		return true;
	if(current.levelString == "/Game/Maps/Music/Ending/Music_Ending_BP" && old.levelString == "/Game/Maps/Music/Nightclub/Music_Nightclub_BP") // Turn up to A Grand Finale
		return true;
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
	}
}