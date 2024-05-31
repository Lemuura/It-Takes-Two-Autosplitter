state("ItTakesTwo", "1.4")
{
	bool isLoading: "ItTakesTwo.exe", 0x07A00020, 0x180, 0x2b0, 0x0, 0x458, 0xf9;
	string255 levelString: "ItTakesTwo.exe", 0x07A00020, 0x180, 0x368, 0x8, 0x1b8, 0x0;
	string255 checkPointString: "ItTakesTwo.exe", 0x07A00020, 0x180, 0x368, 0x8, 0x1d8, 0x0;
	string255 chapterString: "ItTakesTwo.exe", 0x07A00020, 0x180, 0x368, 0x8, 0x1e8, 0x0;
	string255 subchapterString: "ItTakesTwo.exe", 0x07A00020, 0x180, 0x368, 0x8, 0x1f8, 0x0;
	string255 cutsceneString: "ItTakesTwo.exe", 0x07A00020, 0x180, 0x2b0, 0x0, 0x390, 0x2a0, 0x788, 0x0;
	byte skippable: "ItTakesTwo.exe", 0x07A00020, 0x180, 0x2b0, 0x0, 0x390, 0x318;
}

state("ItTakesTwo", "1.3")
{
	bool isLoading: "ItTakesTwo.exe", 0x078115C0, 0x180, 0x2b0, 0x0, 0x458, 0xf9;
	string255 levelString: "ItTakesTwo.exe", 0x078115C0, 0x180, 0x368, 0x8, 0x1b8, 0x0;
	string255 checkPointString: "ItTakesTwo.exe", 0x078115C0, 0x180, 0x368, 0x8, 0x1d8, 0x0;
	string255 chapterString: "ItTakesTwo.exe", 0x078115C0, 0x180, 0x368, 0x8, 0x1e8, 0x0;
	string255 subchapterString: "ItTakesTwo.exe", 0x078115C0, 0x180, 0x368, 0x8, 0x1f8, 0x0;
	string255 cutsceneString: "ItTakesTwo.exe", 0x078115C0, 0x180, 0x2b0, 0x0, 0x390, 0x2a0, 0x788, 0x0;
	byte skippable: "ItTakesTwo.exe", 0x078115C0, 0x180, 0x2b0, 0x0, 0x390, 0x318;
}

state("ItTakesTwo", "1.2")
{
	bool isLoading: "ItTakesTwo.exe", 0x780e460, 0x180, 0x2b0, 0x0, 0x458, 0xf9;
	string255 levelString: "ItTakesTwo.exe", 0x780e460, 0x180, 0x368, 0x8, 0x1b8, 0x0;
	string255 checkPointString: "ItTakesTwo.exe", 0x780e460, 0x180, 0x368, 0x8, 0x1d8, 0x0;
	string255 chapterString: "ItTakesTwo.exe", 0x780e460, 0x180, 0x368, 0x8, 0x1e8, 0x0;
	string255 subchapterString: "ItTakesTwo.exe", 0x780e460, 0x180, 0x368, 0x8, 0x1f8, 0x0;
	string255 cutsceneString: "ItTakesTwo.exe", 0x780e460, 0x180, 0x2b0, 0x0, 0x390, 0x2a0, 0x788, 0x0;
	byte skippable: "ItTakesTwo.exe", 0x780e460, 0x180, 0x2b0, 0x0, 0x390, 0x318; // Any value above 0 is skippable
}

exit
{
	timer.IsGameTimePaused = true;
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
	if (settings["newTimer"])
    {
		if ((current.skippable >= 1 && old.skippable <= 0) || (vars.lastCutsceneOld != vars.lastCutscene && current.skippable >= 1))
		{
			if (vars.exception.Contains(vars.lastCutscene))
			{
				vars.delayTimer = 0;
			}
			else
			{
				vars.cutsceneAmount++;
				vars.delayTimer = 4000; // How long to delay loads during skippable cutscenes
				vars.timePassed = 4000;
			}
		}
	}


	if (current.isLoading)
		return true;
	if (current.levelString == "/Game/Maps/Main/Menu_BP")
		return true;
	if (current.levelString == null) // Make sure this doesn't return null at all during gameplay? should only be null when game is exited
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

	if (old.checkPointString != current.checkPointString)
    {
		vars.CPSub = current.checkPointString + " " + current.subchapterString;
		print("CPSub: " + vars.CPSub);
		print("CP: " + current.checkPointString);
	}
		

	if (settings["cpCount"])
    {
		if (current.checkPointString != old.checkPointString && vars.cpList.Contains(current.checkPointString) && 
			old.checkPointString != "Main Menu")
        {
			// If CP has been obtained, ignore the rest
			if (vars.obtainedCPs.Contains(vars.CPSub))
				return;

			// Count these CPs twice
			if (vars.cpDouble.Contains(current.checkPointString))
				vars.checkpointCount++;

			// Count this CP twice
			if (current.checkPointString == "Intro" && current.levelString == "/Game/Maps/PlayRoom/Hopscotch/Hopscotch_BP")
				vars.checkpointCount++;

			// Add CP to list and count once
			vars.obtainedCPs.Add(vars.CPSub);
			vars.checkpointCount++;
		}

		// Update CP counter
		vars.SetTextComponent("CP: ", vars.checkpointCount.ToString() + "/" + (vars.cpListCount));
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
		vars.SetTextComponent("Cutscene Count:", vars.cutsceneAmount.ToString());
	}
}

onStart
{
	current.cutsceneCount = 0; // Reset cutscene counter
	vars.avgTimePassed.Clear();
	vars.iceCaveDone = 0;
	vars.splitNextLoad = false;
	vars.cutsceneAmount = 0;

	vars.cutsceneSplits.Clear();
	vars.postCutsceneSplits.Clear();
	vars.checkpointSplits.Clear();
	vars.levelSplits.Clear();
	vars.nextLoadSplits.Clear();

	if (settings["cpCount"])
	{
		if (vars.checkpointCount != 1)
			vars.checkpointCount = 1;

		if (settings["levelReset"] && current.checkPointString != "Main Menu")
		{
			if (current.chapterString == "Shed")
				vars.cpListCount = 37;

			if (current.chapterString == "Tree")
				vars.cpListCount = 56;

			if (current.chapterString == "PlayRoom")
				vars.cpListCount = 75;

			if (current.chapterString == "Clockwork")
				vars.cpListCount = 32;

			if (current.chapterString == "SnowGlobe")
				vars.cpListCount = 24;

			if (current.chapterString == "Garden")
				vars.cpListCount = 55;

			if (current.chapterString == "Music")
				vars.cpListCount = 45;
		}
		else
		{
			vars.cpListCount = 324;
		}

		vars.obtainedCPs.Clear();
		vars.obtainedCPs.Add(vars.CPSub);
	}

	if (settings["defaultSplits"])
	{
		vars.cutsceneSplits.AddRange(vars.defaultSplitsCS);
		vars.postCutsceneSplits.AddRange(vars.defaultSplitsPCS);
		vars.checkpointSplits.Add("TerraceProposalCutscene");
		vars.levelSplits.AddRange(vars.defaultSplits);
	}

	if (settings["intermediaries"])
		vars.levelSplits.AddRange(vars.startLevels);

	if (settings["optionalSplits"])
	{
		vars.optionalSplits.Clear();

		// Shed
		if (settings["sidescrollerCP"])
			vars.nextLoadSplits.Add("Side Scroller");

		if (settings["vacuumBattle"])
			vars.cutsceneSplits.Add("CS_Shed_Awakening_Vacuum_Battle");

		// Depths
		if (settings["minigameIntro"])
			vars.cutsceneSplits.Add("CS_Shed_Tambourine_MiniGame_Intro");

		if (settings["preBossDoubleInteract"])
			vars.nextLoadSplits.Add("Pre Boss Double Interact");

		if (settings["toolbossIntro"])
			vars.cutsceneSplits.Add("CS_Shed_Main_ToolBoss_Battle");

		if (settings["toolbossBattle"])
			vars.checkpointSplits.Add("MainBossFightStarted");

		// Captured
		if (settings["tug"])
			vars.checkpointSplits.Add("MINIGAME_TugOfWar");

		// Deeply Rooted
		if (settings["boatStart"])
			vars.levelSplits.Add("/Game/Maps/Tree/Boat/Tree_Boat_BP");

		if (settings["boatSwarm"])
			vars.checkpointSplits.Add("Boat Checkpoint Swarm");

		if (settings["darkroomStart"])
			vars.levelSplits.Add("/Game/Maps/Tree/Darkroom/Tree_Darkroom_BP");

		if (settings["secondLantern"])
			vars.checkpointSplits.Add("SecondLantern");

		if (settings["thirdLantern"])
			vars.checkpointSplits.Add("ThirdLantern");

		if (settings["beetleElevator"])
			vars.levelSplits.Add("/Game/Maps/Tree/WaspNest/WaspsNest_Elevator_BP");

		if (settings["beetleArena"])
			vars.cutsceneSplits.Add("CS_Tree_WaspNest_Arena_Intro");

		// Extermination
		if (settings["planeIntro"])
			vars.cutsceneSplits.Add("CS_Tree_WaspQueenBoss_Arena_PlaneIntro");

		if (settings["smashWood"])
			vars.cutsceneSplits.Add("CS_Tree_WaspQueenBoss_Arena_SmashInWood");

		// Getaway
		if (settings["gliderHalfway"])
			vars.checkpointSplits.Add("Glider halfway through");

		// Pillow Fort
		if (settings["pillowDolls"])
			vars.cutsceneSplits.Add("CS_PlayRoom_PillowFort_Dolls_Dialogue");

		if (settings["pillowFinal"])
			vars.checkpointSplits.Add("PillowfortFinalRoom");

		// Spaced Out
		if (settings["firstPlatform"])
			vars.checkpointSplits.Add("FirstPortalPlatform");

		if (settings["greenPortal"])
			vars.cutsceneSplits.Add("EV_PlayRoom_SpaceStation_BalanceScales_ReturnToPortal");

		if (settings["redPortal"])
			vars.cutsceneSplits.Add("EV_PlayRoom_SpaceStation_Planets_ReturnToPortal");

		if (settings["purplePortal"])
			vars.cutsceneSplits.Add("EV_PlayRoom_SpaceStation_PlasmaBall_ReturnToPortal");

		if (settings["umbrellaPortal"])
			vars.cutsceneSplits.Add("EV_PlayRoom_SpaceStation_SpaceBowl_ReturnToPortal");

		if (settings["pillowPortal"])
			vars.cutsceneSplits.Add("EV_PlayRoom_SpaceStation_LaunchBoard_ReturnToPortal");

		if (settings["cubePortal"])
			vars.cutsceneSplits.Add("EV_PlayRoom_SpaceStation_Electricity_ReturnToPortal");

		if (settings["laserPointer"])
			vars.checkpointSplits.Add("MoonBaboonLaserPointer");

		if (settings["rocketPhase"])
			vars.checkpointSplits.Add("MoonBaboonRocketPhase");

		if (settings["insideUFO"])
			vars.checkpointSplits.Add("MoonBaboonInsideUFO");

		if (settings["eject"])
			vars.cutsceneSplits.Add("CS_PlayRoom_SpaceStation_BossFight_Eject");

		// Hopscotch
		if (settings["grind"])
			vars.checkpointSplits.Add("Grind Section");

		if (settings["closet"])
			vars.checkpointSplits.Add("Closet");

		if (settings["homework"])
			vars.checkpointSplits.Add("HomeWorkSection");

		if (settings["marble"])
			vars.checkpointSplits.Add("Marble Maze Room");

		if (settings["hopDungeon"])
			vars.checkpointSplits.Add("Hopscotch Dungeon");

		if (settings["fidget"])
			vars.checkpointSplits.Add("Fidget Spinners");

		if (settings["void"])
			vars.levelSplits.Add("/Game/Maps/PlayRoom/Hopscotch/VoidWorld_BP");

		if (settings["kaleidoscope"])
			vars.levelSplits.Add("/Game/Maps/PlayRoom/Hopscotch/Kaleidoscope_BP");

		// Dino Land
		if (settings["pteranodon"])
			vars.cutsceneSplits.Add("EV_PlayRoom_DinoLand_PteranodonCrash");


		// Pirates Ahoy
		if (settings["corridor"])
			vars.checkpointSplits.Add("Pirate_Part02_Corridor");

		if (settings["ships"])
			vars.cutsceneSplits.Add("CS_Playroom_Goldberg_Pirate_ShipsIntro");

		if (settings["stream"])
			vars.checkpointSplits.Add("Pirate_Part05_Stream");

		if (settings["pirateBoss"])
			vars.cutsceneSplits.Add("CS_PlayRoom_Goldberg_Pirate_BossIntro_MainScene");

		// Greatest Show
		if (settings["carousel"])
			vars.checkpointSplits.Add("Circus_Carousel");

		if (settings["trapeeze"])
			vars.checkpointSplits.Add("Circus_Trapeeze");

		// Once Upon a Time
		if (settings["crane"])
			vars.checkpointSplits.Add("Castle_Courtyard_CranePuzzle");

		// Dungeon Crawler
		if (settings["postDrawbridge"])
			vars.checkpointSplits.Add("Castle_Dungeon_PostDrawBridge");

		if (settings["postTeleporter"])
			vars.checkpointSplits.Add("Castle_Dungeon_PostTeleporter");

		if (settings["crusherIntro"])
			vars.cutsceneSplits.Add("CS_Playroom_Castle_Dungeon_CrusherIntro");

		if (settings["chess"])
			vars.levelSplits.Add("/Game/Maps/PlayRoom/Chessboard/Castle_Chessboard_BP");

		// Gates of Time
		if (settings["clocktown"])
			vars.cutsceneSplits.Add("CS_ClockWork_Outside_ClockTown_Intro");

		if (settings["hellTower"])
			vars.cutsceneSplits.Add("LS_Clockwork_Outside_ClockTown_RevealHellTower");

		if (settings["birdIntro"])
			vars.cutsceneSplits.Add("CS_ClockWork_Outside_Bird_Intro");

		if (settings["rightTowerDestroyed"])
			vars.checkpointSplits.Add("Right Tower Destroyed");

		// Clockworks
		if (settings["statue"])
			vars.nextLoadSplits.Add("Statue Room");

		if (settings["wallJump"])
			vars.nextLoadSplits.Add("Wall Jump Corridor");

		if (settings["pocketWatch"])
			vars.nextLoadSplits.Add("Pocket Watch Room");

		// A Blast from the Past
		if (settings["afterRewindSmash"])
			vars.cutsceneSplits.Add("CS_Clockwork_UpperTower_LastBoss_AfterRewindSmash");

		// Warming Up
		if (settings["timber"])
			vars.checkpointSplits.Add("Timber");

		if (settings["mill"])
			vars.checkpointSplits.Add("Mill");

		if (settings["flipper"])
			vars.checkpointSplits.Add("Flipper");

		if (settings["cabin"])
			vars.checkpointSplits.Add("Cabin");

		// Winter Village
		if (settings["townDoor"])
			vars.checkpointSplits.Add("Town Door");

		if (settings["bobsledCP"])
			vars.checkpointSplits.Add("Town Bobsled");

		// Beneath the Ice
		if (settings["iceCave"])
			vars.cutsceneSplits.Add("LS_Snowglobe_Lake_IceCaveFinish"); 

		if (settings["lakeIceCave"])
			vars.nextLoadSplits.Add("LakeIceCave");

		//if (settings["fish"])
		//	vars.optionalSplits.Add("CoreBase"); // Check logic for this one

		// Slippery Slopes
		if (settings["iceCaveSlopes"])
			vars.checkpointSplits.Add("1. IceCave");

		if (settings["caveSkating"])
			vars.checkpointSplits.Add("2. CaveSkating");

		if (settings["collapse"])
			vars.checkpointSplits.Add("3. Collapse");

		if (settings["playerAttraction"])
			vars.checkpointSplits.Add("4. PlayerAttraction");

		if (settings["windwalk"])
			vars.checkpointSplits.Add("5. WindWalk");

		// Green Fingers
		if (settings["cactus"])
			vars.checkpointSplits.Add("Cactus Combat Area");

		if (settings["beanstalk"])
			vars.checkpointSplits.Add("Beanstalk Section");

		if (settings["burrown"])
			vars.checkpointSplits.Add("Burrown Enemy");

		if (settings["window"])
			vars.checkpointSplits.Add("Greenhouse Window");

		// Weed Whacking
		if (settings["spiderFight"])
			vars.checkpointSplits.Add("Shrubbery_StartCombat");

		if (settings["secondSpider"])
			vars.checkpointSplits.Add("Shrubbery_SecondSpider");

		if (settings["sinkingLog"])
			vars.checkpointSplits.Add("Shrubbery_SinkingLog");

		if (settings["finalCombat"])
			vars.checkpointSplits.Add("Shrubbery_StartingFinalCombat");

		if (settings["cactusWaves"])
			vars.cutsceneSplits.Add("CS_Garden_Shrubbery_CactusWaves_Intro");

		// Trespassing
		if (settings["stealthStart"])
			vars.checkpointSplits.Add("MoleTunnels_Stealth_Start");

		if (settings["moleChase"])
			vars.checkpointSplits.Add("MoleTunnels_MoleChase_Start");

		if (settings["mole2D"])
			vars.cutsceneSplits.Add("CS_Garden_Moletunnels_Chase_FallDownInto2D");

		if (settings["gnome"])
			vars.checkpointSplits.Add("MoleTunnels_MoleChase_2D_TreasureRoom");



		// Frog Pond
		if (settings["topFountainBulb"])
			vars.checkpointSplits.Add("GrindSection");

		if (settings["snail"])
			vars.checkpointSplits.Add("Minigame_SnailRace");

		// Affliction
		if (settings["firstBulb"])
			vars.checkpointSplits.Add("Greenhouse_FirstBulbExploded");

		if (settings["joyIntro"])
			vars.cutsceneSplits.Add("CS_Garden_GreenHouse_BossRoom_Intro");

		if (settings["joyPhase2"])
			vars.checkpointSplits.Add("Joy_Bossfight_Phase_2");

		if (settings["joyPhase3"])
			vars.checkpointSplits.Add("Joy_Bossfight_Phase_3");

		// Setting the Stage
		if (settings["trackRunner"])
			vars.checkpointSplits.Add("MINIGAME_TrackRunner");

		// Turn Up
		if (settings["djElevator"])
			vars.cutsceneSplits.Add("CS_Music_NightClub_Basement_Elevator");

		if (settings["audioSurf"])
			vars.checkpointSplits.Add("AudioSurf");
	}

	if (settings["commGold"])
    {
		vars.resetCommCP = current.checkPointString;
		print("resetCommCP: " + vars.resetCommCP);
	}
}

start
{
	if (current.isLoading)
	{
		if (vars.startLevels.Contains(current.levelString))
			return true;

		if (settings["commGold"] && vars.commStartLevels.Contains(current.levelString))
			return true;
	}
}

reset
{
	if (current.checkPointString != old.checkPointString || current.isLoading && !old.isLoading)
    {
		if (current.checkPointString == "Awakening_Start")
        {
			return true;
        }

		if (settings["levelReset"])
        {
			if (current.checkPointString == "Intro" && current.levelString == "/Game/Maps/Garden/VegetablePatch/Garden_VegetablePatch_BP")
				return true;

			if (vars.resetIL.Contains(current.checkPointString))
            {
				if (vars.lastCutscene == "CS_SnowGlobe_Forest_Entrance_Intro")
					return false;
				if (old.checkPointString == "Forest Entry")
					return false;
				return true;
			}	
        }

		if (settings["commGold"])
		{
			if (current.checkPointString == vars.resetCommCP)
			{
				if (vars.resetCommException.Contains(old.checkPointString))
					return false;

				print("commGold reset");
				return true;
			}
		}
	}
}

onReset
{
	vars.checkpointCount = 0;
}

split
{
	// Split on next load
	if (vars.splitNextLoad && current.isLoading && !old.isLoading)
	{
		vars.splitNextLoad = false;
		return true;
	}

	if (old.levelString != current.levelString)
    {
		if (vars.levelSplits.Contains(current.levelString) && vars.oldLevelSplits.Contains(old.levelString))
			return true;
	
    }

	if (old.subchapterString != current.subchapterString)
    {
		if (vars.levelSplits.Contains(current.subchapterString) && vars.oldLevelSplits.Contains(old.subchapterString))
			return true;
	}

	if (old.checkPointString != current.checkPointString)
	{
		if (vars.checkpointSplits.Contains(current.checkPointString))
			return true;

		if (vars.nextLoadSplits.Contains(current.checkPointString))
			vars.splitNextLoad = true;
	}

	if (vars.lastCutsceneOld != vars.lastCutscene)
    {
		if (vars.lastCutscene == "CS_Music_Attic_Stage_ClimacticKiss") // Ending split, always active.
			return true;

		if (vars.cutsceneSplits.Contains(vars.lastCutscene))
			return true;

		if (vars.postCutsceneSplits.Contains(vars.lastCutsceneOld))
			return true;

		if (vars.nextLoadSplits.Contains(vars.lastCutscene))
			vars.splitNextLoad = true;
	}
}

init
{
	print(modules.First().ModuleMemorySize.ToString());
  	if (modules.First().ModuleMemorySize == 134217728){
        version = "1.2";
    } else if (modules.First().ModuleMemorySize == 134230016){
        version = "1.3";
    } else {
        version = "1.4"; // 136282112
    }  

	int cutsceneCount = 0; // Initialize cutscene counter
	vars.delayTimer = 0;
	vars.delayTimerTimestamp = 0;
	vars.lastCutscene = "";
	vars.lastCutsceneOld = "";
	vars.checkpointCount = 0;
	vars.timePassed = 0; // Debug value, will remove in the future.
	vars.avgTimePassed = new List<int>() { }; // Debug value, will remove in the future.
	vars.iceCaveDone = 0;
	vars.cutsceneAmount = 0;
	vars.cpListCount = 0;
	vars.resetCommCP = "";
	vars.CPSub = "";

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
	{
		settings.Add("defaultSplits", true, "Default Splits");
		settings.Add("intermediaries", true, "Intermediaries");
		//settings.Add("ending", true, "Split on kiss (end of run)");

		settings.Add("optionalSettings", false, "Optional Settings");
		settings.CurrentDefaultParent = "optionalSettings";
		settings.Add("cpCount", false, "Checkpoint Counter");
		settings.SetToolTip("cpCount", "Toggles a checkpoint counter in your overlay. Useful for 100%.");
		settings.Add("commGold", false, "Comm Gold Resets");
		settings.SetToolTip("commGold", "Turns on Comm Gold resets.");
		settings.Add("levelReset", false, "IL Mode");
		settings.SetToolTip("levelReset", "Turns on IL behaviour, like IL Resets");
		settings.Add("newTimer", false, "Experimental new timer that 'removes' ping");
		settings.SetToolTip("newTimer",
			"This removes up to 4 seconds in skippable cutscenes, \n" +
			"and resumes time either when the 4 seconds run out or the cutscene is skipped. \n" +
			"This should make IGT more fair, no matter who you play with across the world.");



		// Optional Splits
		settings.CurrentDefaultParent = null;
		settings.Add("optionalSplits", false, "Optional Splits");

		settings.CurrentDefaultParent = "optionalSplits";
		settings.Add("shed", false, "The Shed");
		settings.Add("tree", false, "The Tree");
		settings.Add("rose", false, "Rose's Room");
		settings.Add("clock", false, "Cuckoo Clock");
		settings.Add("snow", false, "Snow Globe");
		settings.Add("garden", false, "Garden");
		settings.Add("attic", false, "The Attic");

		settings.CurrentDefaultParent = "shed";
		settings.Add("biting", false, "Biting the Dust");
		settings.Add("depths", false, "The Depths");
		settings.Add("wired", false, "Wired Up");

		settings.CurrentDefaultParent = "biting";
		settings.Add("sidescrollerCP", false, "Side Scroller RCP");
		settings.Add("vacuumBattle", false, "Vacuum Battle Cutscene");

		settings.CurrentDefaultParent = "depths";
		settings.Add("minigameIntro", false, "Minigame Intro Cutscene");
		settings.Add("preBossDoubleInteract", false, "Pre Boss Double Interact CP");
		settings.Add("toolbossIntro", false, "Toolboss Intro Cutscene");
		settings.Add("toolbossBattle", false, "Toolbox boss Battle Cutscene");

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
		settings.Add("pillowDolls", false, "Doll Room Cutscene");
		settings.Add("pillowFinal", false, "Final Room");

		settings.CurrentDefaultParent = "spaced";
		settings.Add("firstPlatform", false, "First Portal Platform");
		settings.Add("greenPortal", false, "Green Portal Ending");
		settings.Add("redPortal", false, "Red Portal Ending");
		settings.Add("purplePortal", false, "Purple Portal Ending");
		settings.Add("umbrellaPortal", false, "Umbrella Portal Ending");
		settings.Add("pillowPortal", false, "Pillow Portal Ending");
		settings.Add("cubePortal", false, "Cube Portal Ending");
		settings.Add("laserPointer", false, "Laser Pointer CP");
		settings.Add("rocketPhase", false, "Rocket Phase CP");
		settings.Add("insideUFO", false, "UFO Start");
		settings.Add("eject", false, "UFO Eject Button");

		settings.CurrentDefaultParent = "hopscotch";
		settings.Add("grind", false, "Grind Section CP");
		settings.Add("closet", false, "Closet CP");
		settings.Add("homework", false, "Homework Section");
		settings.Add("marble", false, "Marble Maze Room");
		settings.Add("hopDungeon", false, "Hopscotch Dungeon CP");
		settings.Add("fidget", false, "Fidget Spinners CP");
		settings.Add("void", false, "Void World");
		settings.Add("kaleidoscope", false, "Kaleidoscope");

		settings.CurrentDefaultParent = "train";

		settings.CurrentDefaultParent = "dino";
		settings.Add("pteranodon", false, "Pteranodon Crash");

		settings.CurrentDefaultParent = "pirates";
		settings.Add("corridor", false, "Corridor CP");
		settings.Add("ships", false, "Ships Intro");
		settings.Add("stream", false, "Stream CP");
		settings.Add("pirateBoss", false, "Boss Intro");

		settings.CurrentDefaultParent = "circus";
		settings.Add("carousel", false, "Carousel CP");
		settings.Add("trapeeze", false, "Trapeeze CP");

		settings.CurrentDefaultParent = "castle";
		settings.Add("crane", false, "Crane Puzzle");

		settings.CurrentDefaultParent = "dungeon";
		settings.Add("postDrawbridge", false, "Post Drawbridge");
		settings.Add("postTeleporter", false, "Teleporter Boss Defeated");
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
		settings.Add("timber", false, "Timber");
		settings.Add("mill", false, "Mill (Cody CP)");
		settings.Add("flipper", false, "Flipper (May CP)");
		settings.Add("cabin", false, "Cabin");

		settings.CurrentDefaultParent = "village";
		settings.Add("townDoor", false, "Town Door");
		settings.Add("bobsledCP", false, "Bobsled CP");
		settings.SetToolTip("bobsledCP",
			"This can trigger 2 places: When you hit the trigger on the mountain, like in Any%. \n" +
			"Or when you interact with the cablecar, this is the one that gives you the actual CP.");


		settings.CurrentDefaultParent = "bti";
		settings.Add("iceCave", false, "Ice Cave Finish CS");
		settings.Add("lakeIceCave", false, "Lake Ice Cave RCP (100%)");
		//settings.Add("fish", false, "Fish RCP (Doesn't work atm)");

		settings.CurrentDefaultParent = "slopes";
		settings.Add("iceCaveSlopes", false, "Ice Cave");
		settings.Add("caveSkating", false, "Cave Skating");
		settings.Add("collapse", false, "Collapse");
		settings.Add("playerAttraction", false, "Player Attraction");
		settings.Add("windWalk", false, "Wind Walk");

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
		settings.Add("spiderFight", false, "First combat area cutscene");
		settings.Add("secondSpider", false, "Second Spider");
		settings.Add("sinkingLog", false, "Sinking Log");
		settings.Add("finalCombat", false, "Starting Final Combat RCP");
		settings.Add("cactusWaves", false, "Cactus Waves Intro");

		settings.CurrentDefaultParent = "trespassing";
		settings.Add("stealthStart", false, "Stealth Start CP");
		settings.Add("moleChase", false, "Mole Chase start");
		settings.Add("mole2D", false, "Mole 2D start");
		settings.Add("gnome", false, "Gnome CP");

		settings.CurrentDefaultParent = "frog";
		settings.Add("topFountainBulb", false, "Top Fountain Bulb CS");
		settings.Add("snail", false, "Snail Race");

		settings.CurrentDefaultParent = "affliction";
		settings.Add("firstBulb", false, "First Bulb Exploded");
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

	vars.optionalSplits = new List<string>() { };

	vars.defaultSplits = new List<string>()
	{
		"/Game/Maps/Shed/Vacuum/Vacuum_BP",
		"/Game/Maps/Shed/Main/Main_Hammernails_BP",
		"/Game/Maps/Shed/Main/Main_Grindsection_BP",
		"/Game/Maps/RealWorld/RealWorld_Shed_StarGazing_Meet_BP",
		"/Game/Maps/Tree/SquirrelHome/SquirrelHome_BP_Mech",
		"/Game/Maps/Tree/WaspNest/WaspsNest_BP",
		"/Game/Maps/Tree/Boss/WaspQueenBoss_BP",
		"/Game/Maps/Tree/Escape/Escape_BP",
		"/Game/Maps/PlayRoom/Spacestation/Spacestation_Hub_BP",
		"/Game/Maps/PlayRoom/Hopscotch/Hopscotch_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Trainstation_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Pirate_BP",
		"/Game/Maps/PlayRoom/Courtyard/Castle_Courtyard_BP",
		"/Game/Maps/PlayRoom/Dungeon/Castle_Dungeon_BP",
		"/Game/Maps/PlayRoom/Shelf/Shelf_BP",
		"/Game/Maps/RealWorld/RealWorld_RoseRoom_Bed_Tears_BP",
		"/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_CrushingTrapRoom_BP",
		"/Game/Maps/Clockwork/UpperTower/Clockwork_ClockTowerLastBoss_BP",
		"/Game/Maps/SnowGlobe/Town/SnowGlobe_Town_BP",
		"/Game/Maps/SnowGlobe/Lake/Snowglobe_Lake_BP",
		//"/Game/Maps/SnowGlobe/Mountain/SnowGlobe_Mountain_BP",
		"/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_BP",
		"/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Stealth_BP",
		"/Game/Maps/Garden/FrogPond/Garden_FrogPond_BP",
		"/Game/Maps/Garden/Greenhouse/Garden_Greenhouse_BP",
		"/Game/Maps/Music/Nightclub/Music_Nightclub_BP",
		"/Game/Maps/Music/Backstage/Music_Backstage_Tutorial_BP",
		"/Game/Maps/Music/Classic/Music_Classic_Organ_BP",
		"/Game/Maps/Music/Ending/Music_Ending_BP",

		"SnowGlobe_Mountain",

	};

	vars.defaultSplitsCS = new List<string>()
	{
		"CS_RealWorld_House_LivingRoom_Headache",
		"CS_ClockWork_UpperTower_EndingRewind",
		"CS_Garden_GreenHouse_BossRoom_Outro",
	};

	vars.defaultSplitsPCS = new List<string>()
	{
		"CS_PlayRoom_DinoLand_DinoCrash_Intro",
		"CS_PlayRoom_Circus_Balloon_Intro",
	};

	vars.oldLevelSplits = new List<string>()
	{
		"/Game/Maps/Shed/Awakening/Awakening_BP",
		"/Game/Maps/Shed/Vacuum/Vacuum_BP",
		"/Game/Maps/Shed/Main/Main_Hammernails_BP",
		"/Game/Maps/Shed/Main/Main_Bossfight_BP",
		"/Game/Maps/Shed/Main/Main_Grindsection_BP",
		"/Game/Maps/RealWorld/RealWorld_Shed_StarGazing_Meet_BP",
		"/Game/Maps/Tree/SquirreTurf/SquirrelTurf_WarRoom_BP",
		"/Game/Maps/Tree/SquirrelHome/SquirrelHome_BP_Mech",
		"/Game/Maps/Tree/WaspNest/WaspsNest_BeetleRide_BP",
		"/Game/Maps/Tree/SquirreTurf/SquirrelTurf_Flight_BP",
		"/Game/Maps/RealWorld/RealWorld_Exterior_Roof_Crash_BP",
		"/Game/Maps/PlayRoom/PillowFort/PillowFort_BP",
		"/Game/Maps/RealWorld/Realworld_SpaceStation_Bossfight_BeamOut_BP",
		"/Game/Maps/PlayRoom/Hopscotch/Kaleidoscope_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Trainstation_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Dinoland_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Pirate_BP",
		"/Game/Maps/PlayRoom/Goldberg/Goldberg_Circus_BP",
		"/Game/Maps/PlayRoom/Courtyard/Castle_Courtyard_BP",
		"/Game/Maps/PlayRoom/Chessboard/Castle_Chessboard_BP",
		"/Game/Maps/PlayRoom/Shelf/Shelf_BP",
		"/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Time_BP",
		"/Game/Maps/Clockwork/Outside/Clockwork_ClockTowerCourtyard_BP",
		"/Game/Maps/Clockwork/Outside/Clockwork_Forest_BP",
		"/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_CuckooBirdRoom_BP",
		"/Game/Maps/Clockwork/LowerTower/Clockwork_ClockTowerLower_EvilBirdRoom_BP",
		"/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Attraction_BP",
		"/Game/Maps/SnowGlobe/Forest/SnowGlobe_Forest_BP",
		"/Game/Maps/SnowGlobe/Forest/SnowGlobe_Forest_TownGate_BP",
		"/Game/Maps/SnowGlobe/Town/SnowGlobe_Town_BobSled",
		//"/Game/Maps/SnowGlobe/Lake/Snowglobe_Lake_BP",
		"/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Garden_BP",
		"/Game/Maps/Garden/VegetablePatch/Garden_VegetablePatch_BP",
		"/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_SecondCombat_BP",
		"/Game/Maps/Garden/Shrubbery/Garden_Shrubbery_BP",
		"/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Chase_BP",
		"/Game/Maps/Garden/MoleTunnels/Garden_MoleTunnels_Stealth_BP",
		"/Game/Maps/Garden/FrogPond/Garden_FrogPond_BP",
		"/Game/Maps/TherapyRoom/TherapyRoom_Session_Theme_Music_BP",
		"/Game/Maps/Music/ConcertHall/Music_ConcertHall_BP",
		"/Game/Maps/Music/Nightclub/Music_Nightclub_BP",

		"/Game/Maps/Tree/WaspNest/WaspsNest_BP",
		"/Game/Maps/Tree/WaspNest/WaspsNest_Swarm_BP",
		"/Game/Maps/Tree/Boat/Tree_Boat_BP",
		"/Game/Maps/Tree/Darkroom/Tree_Darkroom_BP",
		"/Game/Maps/PlayRoom/Hopscotch/Hopscotch_BP",
		"/Game/Maps/PlayRoom/Hopscotch/VoidWorld_BP",
		"/Game/Maps/PlayRoom/Dungeon/Castle_Dungeon_BP",
		"/Game/Maps/PlayRoom/Dungeon/Castle_Dungeon_Charger_BP",

		"SnowGlobe_Lake",
	};

	vars.cutsceneSplits = new List<string>() { };
	vars.postCutsceneSplits = new List<string>() { };
	vars.checkpointSplits = new List<string>() { };
	vars.levelSplits = new List<string>() { };
	vars.nextLoadSplits = new List<string>() { };
	vars.obtainedCPs = new List<string>() { };

	vars.resetIL = new List<string>()
	{
		"Tree_Approach_LevelIntro",
		"PillowFort",
		"ClockworkIntro",
		"ConcertHall_Backstage",
		"Forest Entry",
	};

	vars.resetComm = new List<string>()
	{
		"VacuumIntro",
		"MineIntro",
		"GrindSection_Start",
		"Tree_Approach_LevelIntro",
		"Entry",
		"StartWaspBossPhase1",
		"Intro",
		"PillowFort",
		"SpaceStationIntro",
		"Trainstation_Start",
		"Dinoland_Start",
		"Pirate_Part01_Start",
		"Circus_Start",
		"Castle_Courtyard_Start",
		"Castle_Dungeon",
		"Shelf_Cutie_Intro",
		"ClockworkIntro",
		"Crusher Trap Room",
		"Boss Intro",
		"Forest Entry",
		"Town Entry",
		"0. Entry",
		"Shrubbery_Enter",
		"MoleTunnels_Level_Intro",
		"Greenhouse_Intro",
		"ConcertHall_Backstage",
		"Tutorial_Intro",
		"Classic_01_Attic_Intro",
		"RainbowSlide",
		"EndingIntro",
	};

	vars.resetCommException = new List<string>()
	{
		"Side Scroller",
		"LoadDinoLand",
		"Pirate_Part09_BossEnd",
		"Pirate_Part09_BossEndWithoutCutscene",
		//"GrindSection_Start",
		//"Boss Intro",
	};

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

	vars.cpDouble = new List<string>()
	{
		"GrindSection_Start",
		"Pirate_Part09_BossEnd",
		"Tower Courtyard",
		"Statue Room - Both Side Rooms Completed",
		"Boss Intro",
	};

	vars.cpList = new List<string>()
	{
		"Awakening_Start",
		"Awakening_FirstGameplay",
		"VacuumIntro",
		"VacuumNoIntro",
		"Oil Pit",
		"Behind Boss",
		"Generator",
		"Side Scroller",
		"Stomach",
		"Portal Loop",
		"Weather Vane",
		"Weight Bowl",
		"VacuumBoss",
		"BossNoIntro",
		"MineIntro",
		"MineIntroNoCutscene",
		"TutorialPuzzle1",
		"TutorialPuzzle2",
		"MineMainHub",
		"WhackACody Machine Room Intro",
		"MachineIntroPuzzle1",
		"MineMachineRoom",
		"MineMachineRoomHalfway",
		"MachineRoomChickenRace",
		"MachineRoomEnding",
		"Pre Boss Double Interact",
		"ToolBoxBossIntro",
		"ToolBoxBossHalfWay",
		"MainBossFightStarted",
		"MainBossFightPhase1",
		"MainBossFightPhase2",
		"ToolBoxBossDefeat",
		"GrindSection_Start", // Count as 2 bc of below
		//"GrindSection_Start_PostCutscene", // You only get this one from RCPing
		"GrindSection_SwapTracks",
		"GrindSection_ConnectCables",
		"GrindSection_PostFan",
		"Tree_Approach_LevelIntro",
		"Tree_Approach_LevelStart",
		"Entry",
		"Entry (No cutscene)",
		"Elevator",
		"Bridge",
		"HangingStuff",
		"BigWheels",
		"Lift",
		"First Contact",
		"Ovens",
		"Crossing",
		"Rails",
		"Vault",
		"Vault ShieldWasp",
		//"Entry", // Same name as other subchapter                       // FIX FOR CP COUNTER
		//"Entry (No cutscene)", // Same name as other subchapter         // FIX FOR CP COUNTER
		"Larva",
		"Bottles",
		"Swarm",
		"Slide",
		"SlidePart1",
		"SlidePart2",
		"SlidePart3",
		"Boat (Cutscene)",
		"Boat (No cutscene)",
		"Boat Checkpoint Calm",
		"Boat Checkpoint Swarm",
		"DarkRoom (Cutscene)",
		"DarkRoom (No cutscene)",
		"FirstLantern",
		"SecondLantern",
		"ThirdLantern",
		"DarkRoom FlyingAnimal",
		"Elevator (Cutscene)",
		"Elevator (No cutscene)",
		"Elevator Start",
		"Elevator (ShieldWasp)",
		"Beetle",
		"Beetle Ride",
		"BeetleRide_Part1",
		"BeetleRide_Part2",
		"BeetleRide_Part3",
		"BeetleRide_Part4",
		"BeetleRide_Part5",
		"StartWaspBossPhase1",
		"StartWaspBossPhase1_NoCutscene", // You only get this from RCPing        // FIX FOR CP COUNTER
		"ShotOffFirstArmour",
		"StartWaspBossPhase3",
		"Intro",
		"Before Catapult Room",
		"AfterSquirrelChaseCS",
        //"House Reveal", // DEV CP
        "Fight outside tree",
		"Glider Checkpoint",
		"Glider in tunnel",
		"Glider halfway through",
		"PillowFort",
		"Pillowfort Intro No CS",
		"PillowfortFinalRoom",
		"SpaceStationIntro",
		"SpaceStationNoIntro",
		"FirstPortalPlatform",
		"FirstPortalPlatformCompleted",
		"SecondPortalPlatform",
		"SecondPortalPlatformCompleted",
		"MoonBaboonIntro",
		"MoonBaboonLaserPointer",
		"MoonBaboonRocketPhase",
		"MoonBaboonInsideUFO",
		"MoonBaboonInsideUFO_Pedal",
		"MoonBaboonInsideUFO_Crusher",
		"MoonBaboonInsideUFO_ElectricWall",
		"MoonBaboonMoon",
		//"Intro", // Same name as other subchapter // Count as 2 bc of below      // FIX FOR CP COUNTER
		//"Intro - No Cutscene", // Only obtained through RCP                      // FIX FOR CP COUNTER
		"Grind Section",
		"Closet",
		"Coathanger Ropeway",
		"HomeWorkSection",
		"Marble Maze Room",
		"Hopscotch Dungeon",
		"Hopscotch Dungeon - Whoopee Cushions",
		"First Ball Fall",
		"Fidget Spinners",
		"Fidget Spinner Tunnel",
		//"Elevator", // Same name as other subchapter                               // FIX FOR CP COUNTER
		"Void World",
		"Spawning Floor",
		"Kaleidoscope Intro",
		"Trainstation_Start",
		"Trainstation_Start_NoCutscene",
		"Dinoland_Start",
		"Dinoland_SlamDinoPt1",
		"Dinoland_SlamDinoPt2",
		"Dinoland_Platforming",
		"Pirate_Part01_Start",
		"Pirate_Part01_StartWithoutCutscene",
		"Pirate_Part02_Corridor",
		"Pirate_Part03_PirateShips",
		"Pirate_Part04_PirateShips_End",
		"Pirate_Part05_Stream",
		//"Pirate_Part06_BossCutScene", // Not obtained in normal gameplay
		"Pirate_Part06_BossStart",
		"Pirate_Part07_BossHalfway",
		"Pirate_Part08_BossFinalPart",
		"Pirate_Part09_BossEnd", // Count as 2 bc of below
		//"Pirate_Part09_BossEndWithoutCutscene", // Only obtained through RCP
		"Circus_Start",
		"Circus_HamsterWheel",
		"Circus_Carousel",
		"Circus_Cannon",
		"Circus_Monowheel",
		"Circus_Trapeeze",
		"Castle_Courtyard_Start",
		"Castle_Courtyard_Start_NoIntro",
		"Castle_Courtyard_CranePuzzle",
		"Castle_Dungeon",
		"Castle_Dungeon_NoCutscene",
		"Castle_Dungeon_DrawBridge",
		"Castle_Dungeon_PostDrawBridge",
		"Castle_Dungeon_Teleporter",
		"Castle_Dungeon_PostTeleporter",
		"Castle_Dungeon_FirePlatforms",
		"Castle_Dungeon_CrusherConnector",
		"Castle_Dungeon_Crusher",
		"Castle_Dungeon_ChargerConnector",
		"Castle_Dungeon_Charger",
		"Castle_Chessboard_Intro",
		"Castle_Chessboard_BossFIght",
		"Shelf_Cutie_Intro",
		"Shelf_Cutie",
		"Shelf_CutieStuckInHatch",
		"ClockworkIntro",
		"Clockwork Intro - No Cutscene",
		"ClockTown",
		"ClockTown_NoIntro",
		"ClockTown_Valves",
		"Start Forest",
		"Forest - No Cutscene",
		//"Left Tower Puizzle", // Not obtained in normal gameplay
		//"Right Tower Puzzle", // Not obtained in normal gameplay
		"Left Tower Destroyed",
		"Right Tower Destroyed",
		"Tower Courtyard", // Always obtained on the second tower destroyed, replacing the one above, count as 2
		"Crusher Trap Room",
		"Crusher Room - No Intro",
		//"Bridge", // Same name as other subchapter            // FIX FOR CP COUNTER
		"Statue Room",
		"Statue Room - Mech Wall Room Done",
		"Statue Room - Cage Puzzle Done",
		"Statue Room - Both Side Rooms Completed", // Always obtained on second room finished, replacing the one above, count as 2
		"Mini Boss Fight",
		"Wall Jump Corridor",
		"Elevator Room",
		"Pocket Watch Room",
		//"Path to Evil Bird", // Not obtained in normal gameplay
		"Evil Bird Room",
		"Evil Bird Room Started",
		"Boss Intro", // Count as 2 bc of below
		//"Boss Intro - No cutscene", // Obtained through RCP
		"Boss Swinging Pendulums",
		"Boss Clock Launch to Free Fall",
		"Boss Rewind Smasher",
		"Explosion",
		"Final Explosion",
		"Sprint To Couple",
		"Clockwork Ending",
        "Forest Entry",
        "Gate",
        "Timber",
		"Mill",
		"Flipper",
		"Cabin",
		"CaveTownGate",
		"Town Entry",
		"Town Entry (No cutscene)",
		"Town Door",
		"Town Bobsled",
		//"Entry", // Same name as other subchapter                        // FIX FOR CP COUNTER
		//"Entry (No cutscene)", // Same name as other subchapter          // FIX FOR CP COUNTER
		"CoreBase",
		"IceCave Complete",
		"LakeIceCave",
		"0. Entry",
		//"Entry (No cutscene)", // Same name as other subchapter         // FIX FOR CP COUNTER
		"1. IceCave",
		"2. CaveSkating",
		"3. Collapse",
		"4. PlayerAttraction",
		"5. WindWalk",
		"TerraceProposalCutscene",
		//"Intro", // Same name as other subchapter                         // FIX FOR CP COUNTER
		"Intro_NoCutscene",
		"Cactus Combat Area",
		"Beanstalk Section",
		"Burrown Enemy",
		"Burrown Enemy Combat",
		"Greenhouse Window",
		"Shrubbery_Enter",
		"Shrubbery_Enter_NoIntro",
		"Shrubbery_Sprinkler",
		"Shrubbery_StartCombat",
		"Shrubbery_FirstCombatFinished",
		"Shrubbery_DandelionLaunchers",
		"Shrubbery_SecondSpider",
		"Shrubbery_SpinningLog",
		"Shrubbery_EnteringBigLog",
		"Shrubbery_SinkingLog",
		"Shrubbery_PurpleSapWall",
		"Shrubbery_AfterLeavingSpiders",
		"Shrubbery_StartingFinalCombat",
		"Shrubbery_StartingFinalCombatSecondWave",
		//"Shrubbery_SecondCombatFirstWaveFinished", // Weird, not listed in dev menu, only gotten through RCP, not in save file.
		//"Shrubbery_Outro", // Dev CP
        "MoleTunnels_Level_Intro",
		"MoleTunnels_Level_Start",
		"MoleTunnels_Stealth_Start",
		"MoleTunnels_Stealth_SneakyBushStart",
		"MoleTunnels_Stealth_SneakyBushMiddle",
		"MoleTunnels_Stealth_SneakyBushEnding",
		"MoleTunnels_Stealth_Finished",
		"MoleTunnels_MoleChase_Start",
		"MoleTunnels_MoleChase_TopDown",
		"MoleTunnels_MoleChase_TopDown_SafeRoom",
		"MoleTunnels_MoleChase_2D",
		"MoleTunnels_MoleChase_2D_TreasureRoom",
		//"Intro", // Same name as other subchapter                          // FIX FOR CP COUNTER
		"FrogPondIntroNoCS",
		"LilyPads",
		"Scale Puzzle",
		"Sinking Puzzle",
		"Frogger",
		"Fish Fountain Puzzle",
		"Main Fountain Puzzle",
		"Top of Main Fountain",
		"GrindSection",
		"Greenhouse Window Puzzle",
		"Greenhouse_Intro",
		"Greenhouse_StartGameplay",
		"Greenhouse_FirstBulbExploded",
		"Joy_Bossfight_Intro",
		"Joy_Bossfight_Phase_1_Combat",
		"Joy_Bossfight_Phase_2",
		"Joy_Bossfight_Phase_2_5",
		"Joy_Bossfight_Phase_2_Combat",
		"Joy_Bossfight_Phase_3",
		"Joy_Bossfight_Phase_3_5",
		"Joy_Bossfight_Phase_3_Combat",
		"ConcertHall_Backstage",
		"ConcertHall_Backstage_NoCS",
		"Tutorial_Intro",
		"Tutorial_Start",
		"Tutorial_Disk_Puzzle",
		"JukeboxStart",
		"Jukebox_CoinSlot",
		"JukeboxVinyl",
		"PrePortableSpeaker",
		"PortableSpeaker",
		"Sub Bass Room",
		"Truss Room",
		"Music Tech Wall - Start",
		"Silent Room Intro",
		"Silent Room Elevator Pillar",
		"Silent Room End",
		"MicrophoneChase",
		"MicrophoneChase After First Grind",
		"MicrophoneChase Ending",
		"DrumMachineRoom",
		"LightRoom",
		"ConcertHall_Classic",
		"ConcertHall_Classic_NoCS",
		"Classic_01_Attic_Intro",
		"Classic_01_Attic",
		"Classic_02_FlutePuzzle",
		"Classic_03_AccordionBox",
		"Classic_04_BridgePuzzle",
		"Classic_05_ShutterPuzzle",
		"Classic_06_Heaven",
		"Classic_07_Heaven_CageArea",
		"Classic_08_Heaven_CloudArea",
		"ConcertHall_NightClub",
		"ConcertHall_NightClub_NoCS",
		"RainbowSlide",
		"RainBowSlideNoCutscene",
		"Slide ending",
		"Beat platforming",
		"Pre DiscoballRide",
		"DiscoBallRide",
		"Basement / pre elevator",
		"DJ-Dancefloor",
		"AudioSurf",
		"EndingIntro",
		"MayInDressingRoom",
	};

}