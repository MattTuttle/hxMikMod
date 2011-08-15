/**
 *
 * hxMikMod sound library
 * Copyright (C) 2011 Jouko Pynnönen <jouko@iki.fi>
 *             
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

package hxmikmod;

import hxmikmod.structure.Instrument;
import hxmikmod.structure.ModControl;
import hxmikmod.structure.Module;
import hxmikmod.structure.ModVoice;
import hxmikmod.structure.Sample;

import hxmikmod.loaders.ModuleLoader;
import hxmikmod.event.TrackerEvent;
import hxmikmod.event.TrackerEventDispatcher;

typedef Effect_func = Int->Int->ModControl->Module-> Int->Int;

class MPlayer
{
	public static var pf:Module;
	inline static var HIGH_OCTAVE = 2;
	
	static var effects = [
		DoNothing,      /* 0 */
		DoNothing,      /* UNI_NOTE */
		DoNothing,      /* UNI_INSTRUMENT */
		DoPTEffect0,    /* UNI_PTEFFECT0 */
		DoPTEffect1,    /* UNI_PTEFFECT1 */
		DoPTEffect2,    /* UNI_PTEFFECT2 */
		DoPTEffect3,    /* UNI_PTEFFECT3 */
		DoPTEffect4,    /* UNI_PTEFFECT4 */
		DoPTEffect5,    /* UNI_PTEFFECT5 */
		DoPTEffect6,    /* UNI_PTEFFECT6 */
		DoPTEffect7,    /* UNI_PTEFFECT7 */
		DoPTEffect8,    /* UNI_PTEFFECT8 */
		DoPTEffect9,    /* UNI_PTEFFECT9 */
		DoPTEffectA,    /* UNI_PTEFFECTA */
		DoPTEffectB,    /* UNI_PTEFFECTB */
		DoPTEffectC,    /* UNI_PTEFFECTC */
		DoPTEffectD,    /* UNI_PTEFFECTD */
		DoPTEffectE,    /* UNI_PTEFFECTE */
		DoPTEffectF,    /* UNI_PTEFFECTF */
		DoS3MEffectA,   /* UNI_S3MEFFECTA */
		DoS3MEffectD,   /* UNI_S3MEFFECTD */
		DoS3MEffectE,   /* UNI_S3MEFFECTE */
		DoS3MEffectF,   /* UNI_S3MEFFECTF */
		DoS3MEffectI,   /* UNI_S3MEFFECTI */
		DoS3MEffectQ,   /* UNI_S3MEFFECTQ */
		DoS3MEffectR,   /* UNI_S3MEFFECTR */
		DoS3MEffectT,   /* UNI_S3MEFFECTT */
		DoS3MEffectU,   /* UNI_S3MEFFECTU */
		DoKeyOff,       /* UNI_KEYOFF */
		DoKeyFade,      /* UNI_KEYFADE */
		DoVolEffects,   /* UNI_VOLEFFECTS */
		DoPTEffect4,    /* UNI_XMEFFECT4 */
		DoXMEffect6,    /* UNI_XMEFFECT6 */
		DoXMEffectA,    /* UNI_XMEFFECTA */
		DoXMEffectE1,   /* UNI_XMEFFECTE1 */
		DoXMEffectE2,   /* UNI_XMEFFECTE2 */
		DoXMEffectEA,   /* UNI_XMEFFECTEA */
		DoXMEffectEB,   /* UNI_XMEFFECTEB */
		DoXMEffectG,    /* UNI_XMEFFECTG */
		DoXMEffectH,    /* UNI_XMEFFECTH */
		DoXMEffectL,    /* UNI_XMEFFECTL */
		DoXMEffectP,    /* UNI_XMEFFECTP */
		DoXMEffectX1,   /* UNI_XMEFFECTX1 */
		DoXMEffectX2,   /* UNI_XMEFFECTX2 */
		DoITEffectG,    /* UNI_ITEFFECTG */
		DoITEffectH,    /* UNI_ITEFFECTH */
		DoITEffectI,    /* UNI_ITEFFECTI */
		DoITEffectM,    /* UNI_ITEFFECTM */
		DoITEffectN,    /* UNI_ITEFFECTN */
		DoITEffectP,    /* UNI_ITEFFECTP */
		DoITEffectT,    /* UNI_ITEFFECTT */
		DoITEffectU,    /* UNI_ITEFFECTU */
		DoITEffectW,    /* UNI_ITEFFECTW */
		DoITEffectY,    /* UNI_ITEFFECTY */
		DoNothing,      /* UNI_ITEFFECTZ */
		DoITEffectS0,   /* UNI_ITEFFECTS0 */
	//                DoULTEffect9,   /* UNI_ULTEFFECT9 */
	//                DoMEDSpeed,             /* UNI_MEDSPEED */
	//                DoMEDEffectF1,  /* UNI_MEDEFFECTF1 */
	//                DoMEDEffectF2,  /* UNI_MEDEFFECTF2 */
	//                DoMEDEffectF3,  /* UNI_MEDEFFECTF3 */
	//                DoOktArp,               /* UNI_OKTARP */
	];
	
	static var oldperiods=[
		0x6b00, 0x6800, 0x6500, 0x6220, 0x5f50, 0x5c80,
		0x5a00, 0x5740, 0x54d0, 0x5260, 0x5010, 0x4dc0,
		0x4b90, 0x4960, 0x4750, 0x4540, 0x4350, 0x4160,
		0x3f90, 0x3dc0, 0x3c10, 0x3a40, 0x38b0, 0x3700
	];
	static var VibratoTable=[
	          0, 24, 49, 74, 97,120,141,161,180,197,212,224,235,244,250,253,
	        255,253,250,244,235,224,212,197,180,161,141,120, 97, 74, 49, 24
	   ];
	static var avibtab=[
		 0, 1, 3, 4, 6, 7, 9,10,12,14,15,17,18,20,21,23,
		24,25,27,28,30,31,32,34,35,36,38,39,40,41,42,44,
		45,46,47,48,49,50,51,52,53,54,54,55,56,57,57,58,
		59,59,60,60,61,61,62,62,62,63,63,63,63,63,63,63,
		64,63,63,63,63,63,63,63,62,62,62,61,61,60,60,59,
		59,58,57,57,56,55,54,54,53,52,51,50,49,48,47,46,
		45,44,42,41,40,39,38,36,35,34,32,31,30,28,27,25,
		24,23,21,20,18,17,15,14,12,10, 9, 7, 6, 4, 3, 1
	];
	/* Triton's linear periods to frequency translation table (for XM modules) */
	static var lintab=[
        535232,534749,534266,533784,533303,532822,532341,531861,
        531381,530902,530423,529944,529466,528988,528511,528034,
        527558,527082,526607,526131,525657,525183,524709,524236,
        523763,523290,522818,522346,521875,521404,520934,520464,
        519994,519525,519057,518588,518121,517653,517186,516720,
        516253,515788,515322,514858,514393,513929,513465,513002,
        512539,512077,511615,511154,510692,510232,509771,509312,
        508852,508393,507934,507476,507018,506561,506104,505647,
        505191,504735,504280,503825,503371,502917,502463,502010,
        501557,501104,500652,500201,499749,499298,498848,498398,
        497948,497499,497050,496602,496154,495706,495259,494812,
        494366,493920,493474,493029,492585,492140,491696,491253,
        490809,490367,489924,489482,489041,488600,488159,487718,
        487278,486839,486400,485961,485522,485084,484647,484210,
        483773,483336,482900,482465,482029,481595,481160,480726,
        480292,479859,479426,478994,478562,478130,477699,477268,
        476837,476407,475977,475548,475119,474690,474262,473834,
        473407,472979,472553,472126,471701,471275,470850,470425,
        470001,469577,469153,468730,468307,467884,467462,467041,
        466619,466198,465778,465358,464938,464518,464099,463681,
        463262,462844,462427,462010,461593,461177,460760,460345,
        459930,459515,459100,458686,458272,457859,457446,457033,
        456621,456209,455797,455386,454975,454565,454155,453745,
        453336,452927,452518,452110,451702,451294,450887,450481,
        450074,449668,449262,448857,448452,448048,447644,447240,
        446836,446433,446030,445628,445226,444824,444423,444022,
        443622,443221,442821,442422,442023,441624,441226,440828,
        440430,440033,439636,439239,438843,438447,438051,437656,
        437261,436867,436473,436079,435686,435293,434900,434508,
        434116,433724,433333,432942,432551,432161,431771,431382,
        430992,430604,430215,429827,429439,429052,428665,428278,
        427892,427506,427120,426735,426350,425965,425581,425197,
        424813,424430,424047,423665,423283,422901,422519,422138,
        421757,421377,420997,420617,420237,419858,419479,419101,
        418723,418345,417968,417591,417214,416838,416462,416086,
        415711,415336,414961,414586,414212,413839,413465,413092,
        412720,412347,411975,411604,411232,410862,410491,410121,
        409751,409381,409012,408643,408274,407906,407538,407170,
        406803,406436,406069,405703,405337,404971,404606,404241,
        403876,403512,403148,402784,402421,402058,401695,401333,
        400970,400609,400247,399886,399525,399165,398805,398445,
        398086,397727,397368,397009,396651,396293,395936,395579,
        395222,394865,394509,394153,393798,393442,393087,392733,
        392378,392024,391671,391317,390964,390612,390259,389907,
        389556,389204,388853,388502,388152,387802,387452,387102,
        386753,386404,386056,385707,385359,385012,384664,384317,
        383971,383624,383278,382932,382587,382242,381897,381552,
        381208,380864,380521,380177,379834,379492,379149,378807,
        378466,378124,377783,377442,377102,376762,376422,376082,
        375743,375404,375065,374727,374389,374051,373714,373377,
        373040,372703,372367,372031,371695,371360,371025,370690,
        370356,370022,369688,369355,369021,368688,368356,368023,
        367691,367360,367028,366697,366366,366036,365706,365376,
        365046,364717,364388,364059,363731,363403,363075,362747,
        362420,362093,361766,361440,361114,360788,360463,360137,
        359813,359488,359164,358840,358516,358193,357869,357547,
        357224,356902,356580,356258,355937,355616,355295,354974,
        354654,354334,354014,353695,353376,353057,352739,352420,
        352103,351785,351468,351150,350834,350517,350201,349885,
        349569,349254,348939,348624,348310,347995,347682,347368,
        347055,346741,346429,346116,345804,345492,345180,344869,
        344558,344247,343936,343626,343316,343006,342697,342388,
        342079,341770,341462,341154,340846,340539,340231,339924,
        339618,339311,339005,338700,338394,338089,337784,337479,
        337175,336870,336566,336263,335959,335656,335354,335051,
        334749,334447,334145,333844,333542,333242,332941,332641,
        332341,332041,331741,331442,331143,330844,330546,330247,
        329950,329652,329355,329057,328761,328464,328168,327872,
        327576,327280,326985,326690,326395,326101,325807,325513,
        325219,324926,324633,324340,324047,323755,323463,323171,
        322879,322588,322297,322006,321716,321426,321136,320846,
        320557,320267,319978,319690,319401,319113,318825,318538,
        318250,317963,317676,317390,317103,316817,316532,316246,
        315961,315676,315391,315106,314822,314538,314254,313971,
        313688,313405,313122,312839,312557,312275,311994,311712,
        311431,311150,310869,310589,310309,310029,309749,309470,
        309190,308911,308633,308354,308076,307798,307521,307243,
        306966,306689,306412,306136,305860,305584,305308,305033,
        304758,304483,304208,303934,303659,303385,303112,302838,
        302565,302292,302019,301747,301475,301203,300931,300660,
        300388,300117,299847,299576,299306,299036,298766,298497,
        298227,297958,297689,297421,297153,296884,296617,296349,
        296082,295815,295548,295281,295015,294749,294483,294217,
        293952,293686,293421,293157,292892,292628,292364,292100,
        291837,291574,291311,291048,290785,290523,290261,289999,
        289737,289476,289215,288954,288693,288433,288173,287913,
        287653,287393,287134,286875,286616,286358,286099,285841,
        285583,285326,285068,284811,284554,284298,284041,283785,
        283529,283273,283017,282762,282507,282252,281998,281743,
        281489,281235,280981,280728,280475,280222,279969,279716,
        279464,279212,278960,278708,278457,278206,277955,277704,
        277453,277203,276953,276703,276453,276204,275955,275706,
        275457,275209,274960,274712,274465,274217,273970,273722,
        273476,273229,272982,272736,272490,272244,271999,271753,
        271508,271263,271018,270774,270530,270286,270042,269798,
        269555,269312,269069,268826,268583,268341,268099,267857
	];

	inline static var LOGFAC=2*16;
	static var logtab=[
		LOGFAC*907,LOGFAC*900,LOGFAC*894,LOGFAC*887,
		LOGFAC*881,LOGFAC*875,LOGFAC*868,LOGFAC*862,
		LOGFAC*856,LOGFAC*850,LOGFAC*844,LOGFAC*838,
		LOGFAC*832,LOGFAC*826,LOGFAC*820,LOGFAC*814,
		LOGFAC*808,LOGFAC*802,LOGFAC*796,LOGFAC*791,
		LOGFAC*785,LOGFAC*779,LOGFAC*774,LOGFAC*768,
		LOGFAC*762,LOGFAC*757,LOGFAC*752,LOGFAC*746,
		LOGFAC*741,LOGFAC*736,LOGFAC*730,LOGFAC*725,
		LOGFAC*720,LOGFAC*715,LOGFAC*709,LOGFAC*704,
		LOGFAC*699,LOGFAC*694,LOGFAC*689,LOGFAC*684,
		LOGFAC*678,LOGFAC*675,LOGFAC*670,LOGFAC*665,
		LOGFAC*660,LOGFAC*655,LOGFAC*651,LOGFAC*646,
		LOGFAC*640,LOGFAC*636,LOGFAC*632,LOGFAC*628,
		LOGFAC*623,LOGFAC*619,LOGFAC*614,LOGFAC*610,
		LOGFAC*604,LOGFAC*601,LOGFAC*597,LOGFAC*592,
		LOGFAC*588,LOGFAC*584,LOGFAC*580,LOGFAC*575,
		LOGFAC*570,LOGFAC*567,LOGFAC*563,LOGFAC*559,
		LOGFAC*555,LOGFAC*551,LOGFAC*547,LOGFAC*543,
		LOGFAC*538,LOGFAC*535,LOGFAC*532,LOGFAC*528,
		LOGFAC*524,LOGFAC*520,LOGFAC*516,LOGFAC*513,
		LOGFAC*508,LOGFAC*505,LOGFAC*502,LOGFAC*498,
		LOGFAC*494,LOGFAC*491,LOGFAC*487,LOGFAC*484,
		LOGFAC*480,LOGFAC*477,LOGFAC*474,LOGFAC*470,
		LOGFAC*467,LOGFAC*463,LOGFAC*460,LOGFAC*457,
		LOGFAC*453,LOGFAC*450,LOGFAC*447,LOGFAC*443,
		LOGFAC*440,LOGFAC*437,LOGFAC*434,LOGFAC*431
	];


	static var PanbrelloTable=[
		  0,  2,  3,  5,  6,  8,  9, 11, 12, 14, 16, 17, 19, 20, 22, 23,
		 24, 26, 27, 29, 30, 32, 33, 34, 36, 37, 38, 39, 41, 42, 43, 44,
		 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 56, 57, 58, 59,
		 59, 60, 60, 61, 61, 62, 62, 62, 63, 63, 63, 64, 64, 64, 64, 64,
		 64, 64, 64, 64, 64, 64, 63, 63, 63, 62, 62, 62, 61, 61, 60, 60,
		 59, 59, 58, 57, 56, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46,
		 45, 44, 43, 42, 41, 39, 38, 37, 36, 34, 33, 32, 30, 29, 27, 26,
		 24, 23, 22, 20, 19, 17, 16, 14, 12, 11,  9,  8,  6,  5,  3,  2,
		  0,- 2,- 3,- 5,- 6,- 8,- 9,-11,-12,-14,-16,-17,-19,-20,-22,-23,
		-24,-26,-27,-29,-30,-32,-33,-34,-36,-37,-38,-39,-41,-42,-43,-44,
		-45,-46,-47,-48,-49,-50,-51,-52,-53,-54,-55,-56,-56,-57,-58,-59,
		-59,-60,-60,-61,-61,-62,-62,-62,-63,-63,-63,-64,-64,-64,-64,-64,
		-64,-64,-64,-64,-64,-64,-63,-63,-63,-62,-62,-62,-61,-61,-60,-60,
		-59,-59,-58,-57,-56,-56,-55,-54,-53,-52,-51,-50,-49,-48,-47,-46,
		-45,-44,-43,-42,-41,-39,-38,-37,-36,-34,-33,-32,-30,-29,-27,-26,
		-24,-23,-22,-20,-19,-17,-16,-14,-12,-11,- 9,- 8,- 6,- 5,- 3,- 2
	];



	/*========== General player functions */

	static function DoNothing(tick:Int,flags:Int,a:ModControl,mod:Module,channel:Int):Int {
		MUnitrk.UniSkipOpcode();
		return 0;
	}

	static function DoArpeggio(tick:Int, flags:Int, a:ModControl, style:Int)
	{
		var note=a.main.note;

		if (a.arpmem != 0)
		{
			switch (style)
			{
				case 0:         /* mod style: N, N+x, N+y */
					switch (tick % 3)
					{
						/* case 0: unchanged */
						case 1:
							note += (a.arpmem >> 4);
						case 2:
							note += (a.arpmem & 0xf);
					}
				case 3:         /* okt arpeggio 3: N-x, N, N+y */
					switch (tick % 3)
					{
						case 0:
							note -= (a.arpmem >> 4);
						/* case 1: unchanged */
						case 2:
							note += (a.arpmem & 0xf);
					}
				case 4:         /* okt arpeggio 4: N, N+y, N, N-x */
					switch (tick % 4)
					{
						/* case 0, case 2: unchanged */
						case 1:
							note += (a.arpmem & 0xf);
						case 3:
							note -= (a.arpmem >> 4);
					}
				case 5:         /* okt arpeggio 5: N-x, N+y, N, and nothing at tick 0 */
					if (tick != 0)
					{
						//if (!tick) break;
						switch (tick % 3)
						{
							/* case 0: unchanged */
							case 1:
								note -= (a.arpmem >> 4);
							case 2:
								note += (a.arpmem & 0xf);
						}
					} // tick!=0
			}
			a.main.period = GetPeriod(flags, note << 1, a.speed);
			a.ownper = 1;
		}
	}

	static function DoPTEffect0(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (tick == 0)
		{
			if (dat == 0 && (flags & Defs.UF_ARPMEM) != 0)
				dat=a.arpmem;
			else
				a.arpmem=dat;
		}
		if (a.main.period != 0)
			DoArpeggio(tick, flags, a, 0);

		return 0;
	}

	static function DoPTEffect1(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (tick == 0 && dat != 0)
			a.slidespeed = dat << 2;
		if (a.main.period != 0)
			if (tick != 0)
				a.tmpperiod -= a.slidespeed;
		return 0;
	}

	static function DoPTEffect2(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (tick == 0 && dat != 0)
			a.slidespeed = dat << 2;
		if (a.main.period != 0)
			if (tick != 0)
				a.tmpperiod += a.slidespeed;
		return 0;
	}

	static function DoToneSlide(tick:Int, a:ModControl)
	{
		if (a.main.fadevol==0)
			a.main.kick = (a.main.kick == Defs.KICK_NOTE)? Defs.KICK_NOTE : Defs.KICK_KEYOFF;
		else
			a.main.kick = (a.main.kick == Defs.KICK_NOTE)? Defs.KICK_ENV : Defs.KICK_ABSENT;

		if (tick != 0)
		{
			var dist:Int;

			/* We have to slide a->main.period towards a->wantedperiod, so compute
			the difference between those two values */
			dist=a.main.period-a.wantedperiod;

			/* if they are equal or if portamentospeed is too big ...*/
			if (dist == 0 || a.portspeed > Math.abs(dist))	// int abs
			{
				/* ...make tmpperiod equal tperiod */
				a.tmpperiod = a.main.period = a.wantedperiod;
			}
			else if (dist > 0)
			{
				a.tmpperiod-=a.portspeed;     
				a.main.period-=a.portspeed; /* dist>0, slide up */
			}
			else
			{
				a.tmpperiod+=a.portspeed;     
				a.main.period+=a.portspeed; /* dist<0, slide down */
			}
		}
		else
		{
			a.tmpperiod = a.main.period;
		}
		a.ownper = 1;
	}

	static function DoPTEffect3(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if ((tick == 0) && (dat != 0))
			a.portspeed = dat << 2;
		if (a.main.period != 0)
			DoToneSlide(tick, a);
		return 0;
	}

	static function DoVibrato(tick:Int, a:ModControl)
	{
		var q:Int;
		var temp = 0; /* silence warning */

		if (tick==0) return;

		q = (a.vibpos >> 2) & 0x1f;

		switch (a.wavecontrol & 3)
		{
			case 0: /* sine */
				temp = VibratoTable[q];
			case 1: /* ramp down */
				q <<= 3;
				if (a.vibpos < 0)
					q = 255 - q;
				temp = q;
			case 2: /* square wave */
				temp = 255;
			case 3: /* random wave */
				temp = getrandom(256);
		}

		temp *= a.vibdepth;
		temp >>= 7; temp <<= 2;

		if (a.vibpos>=0)
			a.main.period = a.tmpperiod + temp;
		else
			a.main.period = a.tmpperiod - temp;
		a.ownper = 1;
		
		if (tick != 0)
			a.vibpos += a.vibspd;
	}

	static function DoPTEffect4(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (tick == 0)
		{
			if (dat & 0x0f != 0) a.vibdepth = dat & 0xf;
			if (dat & 0xf0 != 0) a.vibspd = (dat & 0xf0) >> 2;
		}
		if (a.main.period != 0)
			DoVibrato(tick, a);
		return 0;
	}

	static function DoVolSlide(a:ModControl, dat:Int)
	{
		if (dat & 0xf != 0)
		{
			a.tmpvolume-= (dat & 0x0f);
			if (a.tmpvolume < 0)
				a.tmpvolume = 0;
		}
		else
		{
			a.tmpvolume += (dat >> 4);
			if (a.tmpvolume > 64)
				a.tmpvolume = 64;
		}
	}

	static function DoPTEffect5(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (a.main.period != 0)
			DoToneSlide(tick, a);
		if (tick != 0)
			DoVolSlide(a, dat);
		return 0;
	}

	/* DoPTEffect6 after DoPTEffectA */
	static function DoPTEffect7(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat:Int;
		var q:Int;
		var temp = 0; /* silence warning */

		dat = MUnitrk.UniGetByte();
		if (tick == 0)
		{
			if (dat&0x0f!=0) a.trmdepth=dat&0xf;
			if (dat&0xf0!=0) a.trmspd=(dat&0xf0)>>2;
		}
		if (a.main.period != 0)
		{
			q = (a.trmpos >> 2) & 0x1f;

			switch ((a.wavecontrol >> 4) & 3)
			{
				case 0: /* sine */
					temp=VibratoTable[q];
				case 1: /* ramp down */
					q <<= 3;
					if (a.trmpos < 0) q = 255 - q;
					temp=q;
				case 2: /* square wave */
					temp=255;
				case 3: /* random wave */
					temp=getrandom(256);
			}
			temp *= a.trmdepth;
			temp >>= 6;

			if (a.trmpos >= 0)
			{
				a.volume = a.tmpvolume + temp;
				if (a.volume > 64) a.volume = 64;
			}
			else
			{
				a.volume = a.tmpvolume - temp;
				if (a.volume < 0) a.volume = 0;
			}
			a.ownvol = 1;

			if (tick != 0)
				a.trmpos += a.trmspd;
		}
		return 0;
	}

	static function DoPTEffect8(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (mod.panflag)
			a.main.panning = mod.panning[channel] = dat;
		return 0;
	}

	static function DoPTEffect9(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (tick == 0)
		{
			if (dat != 0)
				a.soffset = dat << 8;
			a.main.start = a.hioffset | a.soffset;

			if ((a.main.s != null) && (a.main.start > a.main.s.length))
				a.main.start = a.main.s.flags & (Defs.SF_LOOP | Defs.SF_BIDI) != 0?a.main.s.loopstart:a.main.s.length;
		}

		return 0;
	}

	static function DoPTEffectA(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat=MUnitrk.UniGetByte();
		if (tick!=0)
			DoVolSlide(a, dat);
		return 0;
	}

	static function DoPTEffect6(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		if (a.main.period != 0)
			DoVibrato(tick, a);
		DoPTEffectA(tick, flags, a, mod, channel);
		return 0;
	}

	static function DoPTEffectB(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int)
	{
		var dat=MUnitrk.UniGetByte();

		if (tick!=0 || mod.patdly2!=0)
			return 0;

		/* Vincent Voois uses a nasty trick in "Universal Bolero" */
		if (dat == mod.sngpos && mod.patbrk == mod.patpos)
			return 0;

		if (!mod.loop && mod.patbrk == 0 &&
			(dat < mod.sngpos ||
				(mod.sngpos == (mod.numpos - 1) && mod.patbrk==0) ||
				(dat == mod.sngpos && (flags & Defs.UF_NOWRAP)!=0)
			))
		{
			/* if we don't loop, better not to skip the end of the
			pattern, after all... so:
			mod.patbrk=0;
			*/
			mod.posjmp = 3;
		}
		else
		{
			/* if we were fading, adjust... */
			if (mod.sngpos == (mod.numpos-1))
				mod.volume = mod.initvolume > 128?128:mod.initvolume;
			mod.sngpos=dat;
			mod.posjmp=2;
			mod.patpos=0;
		}
		
		return 0;
	}

	static function DoPTEffectC(tick:Int,flags:Int,a:ModControl,mod:Module,channel:Int):Int
	{
		var dat=MUnitrk.UniGetByte();
		if (tick!=0) return 0;
		if (dat==255 /* (Int)-1*/ ) a.anote=dat=0;
		/* note cut */ else if (dat>64) dat=64;
		a.tmpvolume=dat;
		return 0;
	}

	static function DoPTEffectD(tick:Int,flags:Int,a:ModControl,mod:Module,channel:Int):Int
	{
		var dat=MUnitrk.UniGetByte();
		if ((tick != 0) || (mod.patdly2 != 0)) return 0;
		
		if ((mod.positions[mod.sngpos] != Defs.LAST_PATTERN) &&
			(dat > mod.pattrows[mod.positions[mod.sngpos]]))
		{
			dat=mod.pattrows[mod.positions[mod.sngpos]];
		}
		mod.patbrk=dat;
		if (mod.posjmp == 0)
		{
			/* don't ask me to explain this code - it makes
			backwards.s3m and children.xm (heretic's version) play
			correctly, among others. Take that for granted, or write
			the page of comments yourself... you might need some
			aspirin - Miod */
			if ((mod.sngpos == mod.numpos - 1) &&
				(dat != 0) &&
				((mod.loop) || (mod.positions[mod.sngpos] == (mod.numpat - 1) && (flags & Defs.UF_NOWRAP == 0))))
			{
				mod.sngpos = 0;
				mod.posjmp = 2;
			}
			else
			{
				mod.posjmp = 3;
			}
		}

		return 0;
	}

	static function DoEEffects(tick:Int,flags:Int,a:ModControl,mod:Module,channel:Int,dat:Int)
	{
		var nib = dat & 0xf;
		switch (dat >> 4)
		{
			case 0x0: /* hardware filter toggle, not supported */
				//break;
			case 0x1: /* fineslide up */
				if (a.main.period != 0)
					if (tick == 0)
						a.tmpperiod -= (nib << 2);
			case 0x2: /* fineslide dn */
				if (a.main.period != 0)
					if (tick == 0)
						a.tmpperiod += (nib << 2);
			case 0x3: /* glissando ctrl */
				a.glissando=nib;
			case 0x4: /* set vibrato waveform */
				a.wavecontrol&=0xf0;
				a.wavecontrol|=nib;
			case 0x5: /* set finetune */
				if (a.main.period!=0)
				{
					if (flags&Defs.UF_XMPERIODS!=0)
						a.speed = nib + 128;
					else
						a.speed = ModuleLoader.finetune[nib];
					a.tmpperiod=GetPeriod(flags, a.main.note<<1,a.speed);
				}
			case 0x6: /* set patternloop */
				if (tick==0)
				{
					// tick!=0 break;
					if (nib!=0)
					{
						/* set reppos or repcnt ? */
						/* set repcnt, so check if repcnt already is set, which means we
						are already looping */
						if (a.pat_repcnt!=0)
						{
							a.pat_repcnt--;
						}
						/* already looping, decrease counter */
						else
						{
						//#if 0
						/* this would make walker.xm, shipped with Xsoundtracker,
						play correctly, but it's better to remain compatible
						with FT2 */
						//                                if ((!(flags&UF_NOWRAP))||(a->pat_reppos!=Defs.POS_NONE))
						//#endif
							a.pat_repcnt=nib; /* not yet looping, so set repcnt */
						}

						/* jump to reppos if repcnt>0 */
						if (a.pat_repcnt != 0)
						{
							if (a.pat_reppos == Defs.POS_NONE)
								a.pat_reppos = mod.patpos - 1;
							if (a.pat_reppos == -1)
							{
								mod.pat_repcrazy=1;
								mod.patpos=0;
							}
							else
							{
								mod.patpos=a.pat_reppos;
							}
						}
						else
						{
							a.pat_reppos=Defs.POS_NONE;
						}
					}
					else
					{
						a.pat_reppos=mod.patpos-1; /* set reppos - can be (-1) */
					}
				} // another break
				//break;
			case 0x7: /* set tremolo waveform */
				a.wavecontrol &= 0x0f;
				a.wavecontrol |= nib << 4;
			case 0x8: /* set panning */
				if (mod.panflag)
				{
					if (nib <= 8)
						nib <<= 4;
					else
						nib *= 17;
					a.main.panning = mod.panning[channel] = nib;
				}
			case 0x9: /* retrig note */
				/* do not retrigger on tick 0, until we are emulating FT2 and effect
				data is zero */
				if (!(tick == 0 && !((flags & Defs.UF_FT2QUIRKS != 0) && (nib == 0))))
				{
					// 2. break;
					/* only retrigger if data nibble > 0, or if tick 0 (FT2 compat) */
					if (nib != 0 || tick == 0)
					{
						if (a.retrig == 0)
						{
							/* when retrig counter reaches 0, reset counter and restart
							the sample */
							if (a.main.period != 0)
								a.main.kick = Defs.KICK_NOTE;
							a.retrig = nib;
						}
						a.retrig--; /* countdown */
					}
				}
			case 0xa: /* fine volume slide up */
				if (tick == 0)
				{
					a.tmpvolume += nib;
					if (a.tmpvolume > 64)
						a.tmpvolume = 64;
				}
			case 0xb: /* fine volume slide dn  */
				if (tick == 0)
				{
					a.tmpvolume-= nib;
					if (a.tmpvolume < 0)
						a.tmpvolume = 0;
				}
			case 0xc: /* cut note */
				/* When tick reaches the cut-note value, turn the volume to
				zero (just like on the amiga) */
				if (tick >= nib)
					a.tmpvolume = 0; /* just turn the volume down */
			case 0xd: /* note delay */
				/* delay the start of the sample until tick==nib */
				if (tick==0)
					a.main.notedelay=nib;
				else if (a.main.notedelay != 0)
					a.main.notedelay--;
			case 0xe: /* pattern delay */
				if (tick == 0)
					if (mod.patdly2 == 0)
						mod.patdly = nib + 1; /* only once, when tick=0 */
			case 0xf: /* invert loop, not supported  */
				//break;
		}
	}  

	static function DoPTEffectE(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		DoEEffects(tick, flags, a, mod, channel, MUnitrk.UniGetByte());
		return 0;
	}

	static function DoPTEffectF(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat=MUnitrk.UniGetByte();
		if (tick != 0 || mod.patdly2 != 0)
			return 0;
		if (mod.extspd && (dat >= mod.bpmlimit))
		{
			mod.bpm = dat;
		}
		else
		{
			if (dat != 0)
			{
				mod.sngspd = (dat >= mod.bpmlimit)?mod.bpmlimit - 1:dat;
				mod.vbtick=0;
			}
		}
		return 0;
	}

	static inline function getrandom(ceil:Int):Int
	{
		return Std.int(Math.random() * ceil);
	}
   
	static function GetPeriod(flags:Int, note:Int, speed:Int):Int
	{
		var ret;
		if (flags & Defs.UF_XMPERIODS != 0)
		{
			if (flags & Defs.UF_LINEAR!=0)
				ret = getlinearperiod(note, speed);
			else
				ret = getlogperiod(note, speed);
		}
		else
		{
			ret = getoldperiod(note, speed);
		}
		return ret;
	}

	public static function getlinearperiod(note:Int, fine:Int):Int
	{
		var t:Int;
		t = ((20 + 2 * HIGH_OCTAVE) * Defs.OCTAVE + 2 - note) * 32 - (fine >> 1);
		return t;
	}

	static function getlogperiod(note:Int, fine:Int):Int
	{
		var n:Int;
		var o:Int;
		var p1:Int;
		var p2:Int;
		var i:Int;

		n = note % (2 * Defs.OCTAVE);
		o = Std.int(note / (2 * Defs.OCTAVE));
		i = (n << 2) + (fine >> 4); /* n*8 + fine/16 */

		p1 = logtab[i];
		p2 = logtab[i + 1];

		return (Interpolate(fine >> 4, 0, 15, p1, p2) >> o);
	}


	/* XM linear period to frequency conversion */
	public static function getfrequency(flags:Int, period:Int):Int
	{
		if (flags & Defs.UF_LINEAR != 0)
		{
			var shift = Std.int((period / 768) - HIGH_OCTAVE);	// cast

			if (shift >= 0)
				return lintab[period % 768] >> shift;
			else
				return lintab[period % 768] << (-shift);
		}
		else
		{
			return Std.int((8363 * 1712) / (period != 0?period:1));
		}
	}

	static function Interpolate(p:Int, p1:Int, p2:Int, v1:Int, v2:Int):Int
	{
		if ((p1 == p2) || (p == p1)) return v1;
		return v1 + Std.int(((p - p1) * (v2 - v1)) / (p2 - p1));	// cast
	}

	static function InterpolateEnv(p:Int, a:EnvelopePoint, b:EnvelopePoint):Int
	{
		return (Interpolate(p, a.pos, b.pos, a.val, b.val));
	}

	static function MP_FindEmptyChannel(mod:Module):Int
	{
		//var a:ModVoice;
		var ai:Int;
		var t:Int;
		var k:Int;
		var tvol:Int;
		var pp:Int;

		for (t in 0 ... MDriver.md_sngchn)
		{
			if (((mod.voice[t].main.kick==Defs.KICK_ABSENT)||
				(mod.voice[t].main.kick==Defs.KICK_ENV))&&
				MDriver.Voice_Stopped_internal(t))
			{
				return t;
			}
		}

		tvol = 0xffffff; t = -1; ai = 0; //a=mod.voice;
		for (k in 0 ... MDriver.md_sngchn)
		{
			var a=mod.voice[ai];
			/* allow us to take over a nonexisting sample */
			if (a.main.s==null)
				return k;
			
			if ((a.main.kick == Defs.KICK_ABSENT) || (a.main.kick == Defs.KICK_ENV))
			{
				pp=a.totalvol<<((a.main.s.flags&Defs.SF_LOOP!=0)?1:0);
				if ((a.master!=null)&&(a==a.master.slave))
				pp<<=2;

				if (pp < tvol)
				{
					tvol = pp;
					t = k;
				}
			}
			ai++; // for loop
		}

		if (tvol > 8000 * 7) return -1;
		return t;
	}

	static function getoldperiod(note:Int, speed:Int):Int
	{
		var n:Int;
		var o:Int;
		/* This happens sometimes on badly converted AMF, and old MOD */
		if (speed == 0)
		{
			return 4242; /* <- prevent divide overflow.. (42 hehe) */
		}
		n = note % (2 * Defs.OCTAVE);
		o = Std.int(note / (2 * Defs.OCTAVE));
		return Std.int(((8363 * oldperiods[n]) >> o) / speed);	// cast
	}

	static function pt_playeffects(mod:Module, channel:Int, a:ModControl):Int
	{
		var tick = mod.vbtick;
		var flags = mod.flags;
		var c:Int;
		var explicitslides = 0;
		var f:Effect_func;
		
		while ((c = MUnitrk.UniGetByte()) != 0)
		{
			f = effects[c];
			if (f != null)
			{
				if (f != DoNothing)
					a.sliding = false;
				explicitslides |= f(tick, flags, a, mod, channel);
			}
			else
			{
				trace("unimpl effect: " + c);
			}
		}
		return explicitslides;
	}

	static function DoPan(envpan:Int, pan:Int):Int
	{
		var newpan:Int;
		newpan = pan + Std.int(((envpan - Defs.PAN_CENTER) * (128 - Math.abs(pan - Defs.PAN_CENTER))) / 128);
		return (newpan<Defs.PAN_LEFT)?Defs.PAN_LEFT:(newpan>Defs.PAN_RIGHT?Defs.PAN_RIGHT:newpan);
	}

	/*========== Envelope helpers */
	static function DoKeyOff(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		a.main.keyoff|=Defs.KEY_OFF;
		if ((0 == (a.main.volflg & Defs.EF_ON)) || (a.main.volflg & Defs.EF_LOOP) != 0)
			a.main.keyoff=Defs.KEY_KILL;
		return 0;
	}

	static function DoKeyFade(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat=MUnitrk.UniGetByte();
		if ((tick >= dat) || (tick == mod.sngspd - 1))
		{
			a.main.keyoff = Defs.KEY_KILL;
			if ((a.main.volflg & Defs.EF_ON) == 0)
				a.main.fadevol = 0;
		}
		return 0;
	}

	/*========== Scream Tracker effects */
	static function DoS3MEffectA(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var speed = MUnitrk.UniGetByte();

		if (tick!=0 || mod.patdly2!=0)
			return 0;

		if (speed > 128)
			speed -= 128;
		if (speed != 0)
		{
			mod.sngspd = speed;
			mod.vbtick = 0;
		}
		return 0;
	}

	static function DoS3MVolSlide(tick:Int, flags:Int, a:ModControl, inf:Int)
	{
		var lo:Int;
		var hi:Int;

		if (inf!=0)
			a.s3mvolslide=inf;
		else
			inf=a.s3mvolslide;

		lo=inf&0xf;
		hi=inf>>4;

		if (lo == 0)
		{
			if ((tick != 0) || (flags & Defs.UF_S3MSLIDES) != 0) a.tmpvolume += hi;
		}
		else
		{
			if (hi == 0)
			{
				if ((tick != 0) || (flags & Defs.UF_S3MSLIDES) != 0) a.tmpvolume-= lo;
			}
			else
			{
				if (lo == 0xf)
				{
					if (tick == 0) a.tmpvolume += (hi != 0?hi:0xf);
				}
				else
				{
					if (hi == 0xf)
					{
						if (tick == 0) a.tmpvolume-= (lo != 0?lo:0xf);
					}
					else
					{
						return;
					}
				}
			}
		}

		if (a.tmpvolume<0)
			a.tmpvolume=0;
		else if (a.tmpvolume>64)
			a.tmpvolume=64;
	}
	
	static function DoS3MEffectD(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		DoS3MVolSlide(tick, flags, a, MUnitrk.UniGetByte());
		return 1;
	}

	static function DoS3MSlideDn(tick:Int, a:ModControl, inf:Int)
	{
		var hi:Int;
		var lo:Int;

		if (inf!=0)
			a.slidespeed=inf;
		else
			inf=a.slidespeed;

		hi=inf>>4;
		lo=inf&0xf;

		if (hi == 0xf)
		{
			if (tick == 0) a.tmpperiod += lo << 2;
		} else
		{
			if (hi == 0xe)
			{
				if (tick == 0) a.tmpperiod += lo;
			}
			else
			{
				if (tick != 0) a.tmpperiod += inf << 2;
			}
		}
	}

	static function DoS3MEffectE(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat=MUnitrk.UniGetByte();
		if (a.main.period!=0)
			DoS3MSlideDn(tick, a,dat);

		return 0;
	}

	static function DoS3MSlideUp(tick:Int, a:ModControl, inf:Int)
	{
		var hi:Int;
		var lo:Int;

		if (inf!=0) a.slidespeed=inf;
		else inf=a.slidespeed;

		hi = inf >> 4;
		lo = inf & 0xf;

		if (hi == 0xf)
		{
			if (tick == 0) a.tmpperiod -= lo << 2;
		}
		else
		{
			if (hi == 0xe)
			{
				if (tick == 0) a.tmpperiod -= lo;
			}
			else
			{
				if (tick != 0) a.tmpperiod -= inf << 2;
			}
		}
	}

	static function DoS3MEffectF(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat=MUnitrk.UniGetByte();
		if (a.main.period != 0)
			DoS3MSlideUp(tick, a, dat);
		return 0;
	}

	static function DoS3MEffectI(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var on:Int;
		var off:Int;

		var inf = MUnitrk.UniGetByte();
		if (inf!=0)
		{
			a.s3mtronof = inf;
		}
		else
		{
			inf = a.s3mtronof;
			if (inf==0)
				return 0;
		}

		if (tick==0)
			return 0;

		on=(inf>>4)+1;
		off=(inf&0xf)+1;
		a.s3mtremor%=(on+off);
		a.volume=(a.s3mtremor<on)?a.tmpvolume:0;
		a.ownvol=1;
		a.s3mtremor++;

		return 0;
	}

   static function DoS3MEffectQ(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int {
        var inf = MUnitrk.UniGetByte();
        if (a.main.period!=0) {
                if (inf!=0) {
                        a.s3mrtgslide=inf>>4;
                        a.s3mrtgspeed=inf&0xf;
                }

                /* only retrigger if low nibble > 0 */
                if (a.s3mrtgspeed>0) {
                        if (a.retrig==0) {
                                /* when retrig counter reaches 0, reset counter and restart the
                                   sample */
                                if (a.main.kick!=Defs.KICK_NOTE) a.main.kick=Defs.KICK_KEYOFF;
                                a.retrig=a.s3mrtgspeed;

                                if ((tick!=0)||(flags&Defs.UF_S3MSLIDES)!=0) {
                                        switch (a.s3mrtgslide) {
                                        case 1,2,3,4,5:
                                                a.tmpvolume-=(1<<(a.s3mrtgslide-1));
                                                //break;
                                        case 6:
                                                a.tmpvolume=Std.int((2*a.tmpvolume)/3);
                                                //break;
                                        case 7:
                                                a.tmpvolume>>=1;
                                                //break;
                                        case 9,0xa,0xb,0xc,0xd:
                                                a.tmpvolume+=(1<<(a.s3mrtgslide-9));
                                                //break;
                                        case 0xe:
                                                a.tmpvolume=(3*a.tmpvolume)>>1;
                                                //break;
                                        case 0xf:
                                                a.tmpvolume=a.tmpvolume<<1;
                                                //break;
                                        }
                                        if (a.tmpvolume<0)
                                                a.tmpvolume=0;
                                        else if (a.tmpvolume>64)
                                                a.tmpvolume=64;
                                }
                        }
                        a.retrig--; /* countdown  */
                }
        }
        return 0;
   }

	static function DoS3MEffectR(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var q:Int;
		var temp=0;   /* silence warning */
		var dat = MUnitrk.UniGetByte();

		if (tick == 0)
		{
			if (dat & 0x0f != 0) a.trmdepth = dat & 0xf;
			if (dat & 0xf0 != 0) a.trmspd = (dat & 0xf0) >> 2;
		}

		q=(a.trmpos>>2)&0x1f;

		switch ((a.wavecontrol >> 4) & 3)
		{
			case 0: /* sine */
				temp=VibratoTable[q];
			case 1: /* ramp down */
				q<<=3;
				if (a.trmpos<0) q=255-q;
				temp=q;
			case 2: /* square wave */
				temp=255;
			case 3: /* random */
				temp=getrandom(256);
		}

		temp*=a.trmdepth;
		temp>>=7;

		if (a.trmpos >= 0)
		{
			a.volume=a.tmpvolume+temp;
			if (a.volume>64) a.volume=64;
		}
		else
		{
			a.volume=a.tmpvolume-temp;
			if (a.volume<0) a.volume=0;
		}
		a.ownvol = 1;

		if (tick!=0)
			a.trmpos+=a.trmspd;

		return 0;
	}

	static function DoS3MEffectT(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var tempo = MUnitrk.UniGetByte();

		if (tick!=0 || mod.patdly2!=0)
			return 0;

		mod.bpm = (tempo < 32) ? 32 : tempo;

		return 0;
	}

	static function DoS3MEffectU(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var q:Int;
		var temp = 0; /* silence warning */
		var dat = MUnitrk.UniGetByte();

		if (tick==0) {
			if (dat & 0x0f != 0) a.vibdepth = dat & 0xf;
			if (dat & 0xf0 != 0) a.vibspd = (dat & 0xf0) >> 2;
		}
		else
		{
			if (a.main.period != 0)
			{
				q=(a.vibpos>>2)&0x1f;

				switch (a.wavecontrol & 3)
				{
					case 0: /* sine */
						temp = VibratoTable[q];
					case 1: /* ramp down */
						q <<= 3;
						if (a.vibpos < 0)
							q = 255 - q;
						temp = q;
					case 2: /* square wave */
						temp = 255;
					case 3: /* random */
						temp = getrandom(256);
				}

				temp *= a.vibdepth;
				temp >>= 8;
				if (a.vibpos>=0)
					a.main.period = a.tmpperiod + temp;
				else
					a.main.period = a.tmpperiod - temp;
				a.ownper = 1;

				a.vibpos += a.vibspd;
			}
		}

		return 0;
	}



   /*========== Fast Tracker effects */

   /* DoXMEffect6 after DoXMEffectA */

   static function DoXMEffectA(tick:Int, flags:Int, a:ModControl,mod:Module, channel:Int):Int {
	var lo:Int;
	var hi:Int;
        var inf = MUnitrk.UniGetByte();
        if (inf!=0)
                a.s3mvolslide = inf;
        else
                inf = a.s3mvolslide;
        
        if (tick!=0) {
                lo=inf&0xf;
                hi=inf>>4;

                if (hi==0) {
                        a.tmpvolume-=lo;
                        if (a.tmpvolume<0) a.tmpvolume=0;
                } else {
                        a.tmpvolume+=hi;
                        if (a.tmpvolume>64) a.tmpvolume=64;
                }
        }

        return 0;
   }


	static function DoXMEffect6(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		if (a.main.period!=0)
			DoVibrato(tick, a);

		return DoXMEffectA(tick, flags, a, mod, channel);
	}

	static function DoXMEffectE1(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat=MUnitrk.UniGetByte();
		if (tick == 0)
		{
			if (dat != 0)
				a.fportupspd = dat;
			if (a.main.period != 0)
				a.tmpperiod -= (a.fportupspd << 2);
		}
		return 0;
	}


	static function DoXMEffectE2(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat=MUnitrk.UniGetByte();
		if (tick == 0)
		{
			if (dat != 0)
				a.fportdnspd = dat;
			if (a.main.period != 0)
				a.tmpperiod += (a.fportdnspd << 2);
		}
		return 0;
	}

	static function DoXMEffectEA(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (tick == 0)
			if (dat != 0)
				a.fslideupspd = dat;
		a.tmpvolume += a.fslideupspd;
		if (a.tmpvolume > 64)
			a.tmpvolume = 64;
		return 0;
	}


	static function DoXMEffectEB(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (tick==0)
			if (dat != 0)
				a.fslidednspd = dat;
		a.tmpvolume-= a.fslidednspd;
		if (a.tmpvolume < 0)
			a.tmpvolume = 0;
		return 0;
	}

	static function DoXMEffectG(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		mod.volume = MUnitrk.UniGetByte() << 1;
		if (mod.volume > 128)
			mod.volume = 128;
		return 0;
	}

	static function DoXMEffectH(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var inf = MUnitrk.UniGetByte();

		if (tick != 0)
		{
			if (inf != 0)
				mod.globalslide = inf;
			else
				inf = mod.globalslide;
			
			if (inf & 0xf0 != 0)
				inf &= 0xf0;
			
			mod.volume = mod.volume + ((inf >> 4) - (inf & 0xf)) * 2;

			if (mod.volume < 0)
				mod.volume = 0;
			else if (mod.volume > 128)
				mod.volume = 128;
		}
		return 0;
	}

	static function DoXMEffectL(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if ((tick == 0) && (a.main.i != null))
		{
			var points:Int;
			var i=a.main.i;
			var aout:ModVoice;

			if ((aout = a.slave) != null)
			{
				if (aout.venv.env != null)
				{
					points = i.vol_env.env[i.vol_env.pts - 1].pos;
					aout.venv.p = aout.venv.env[(dat > points)?points:dat].pos;
				}
				if (aout.penv.env != null)
				{
					points = i.pan_env.env[i.pan_env.pts - 1].pos;
					aout.penv.p = aout.penv.env[(dat > points)?points:dat].pos;
				}
			}
		}
		return 0;
	}

	static function DoXMEffectP(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var inf:Int;
		var lo:Int;
		var hi:Int;
		var pan:Int;

		inf = MUnitrk.UniGetByte();
		if (!mod.panflag)
			return 0;

		if (inf != 0)
			a.pansspd = inf;
		else
			inf = a.pansspd;

		if (tick != 0)
		{
			lo = inf & 0xf;
			hi = inf >> 4;

			/* slide right has absolute priority */
			if (hi != 0)
				lo = 0;

			pan = ((a.main.panning == Defs.PAN_SURROUND)?Defs.PAN_CENTER:a.main.panning) + hi - lo;
			a.main.panning = (pan<Defs.PAN_LEFT)?Defs.PAN_LEFT:(pan>Defs.PAN_RIGHT?Defs.PAN_RIGHT:pan);
		}
		return 0;
	}

	static function DoXMEffectX1(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (dat != 0)
			a.ffportupspd = dat;
		else
			dat = a.ffportupspd;

		if (a.main.period != 0)
		{
			if (tick == 0)
			{
				a.main.period -= dat;
				a.tmpperiod -= dat;
				a.ownper = 1;
			}
		}

		return 0;
	}

	static function DoXMEffectX2(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var dat = MUnitrk.UniGetByte();
		if (dat!=0)
			a.ffportdnspd=dat;
		else
			dat = a.ffportdnspd;
		
		if (a.main.period != 0)
		{
			if (tick == 0)
			{
				a.main.period += dat;
				a.tmpperiod += dat;
				a.ownper = 1;
			}
		}

		return 0;
	}


	/*========== Impulse Tracker effects */

	static function DoITToneSlide(tick:Int, a:ModControl, dat:Int)
	{
		if (dat != 0)
			a.portspeed = dat;

		/* if we don't come from another note, ignore the slide and play the note
		as is */
		if (a.oldnote==0 || a.main.period==0)
			return;
		
		if ((tick==0)&&(a.newsamp!=0))
		{
			a.main.kick = Defs.KICK_NOTE;
			a.main.start = -1;
		}
		else
		{
			a.main.kick = (a.main.kick == Defs.KICK_NOTE)?Defs.KICK_ENV:Defs.KICK_ABSENT;
		}
		
		if (tick!=0)
		{
			var dist:Int;
			/* We have to slide a->main.period towards a->wantedperiod, compute the
			difference between those two values */
			dist = a.main.period - a.wantedperiod;
			/* if they are equal or if portamentospeed is too big... */
			if ((dist==0)||((a.portspeed<<2)>Math.abs(dist))) // optimize: integer abs()?
			/* ... make tmpperiod equal tperiod */
			{
				a.tmpperiod=a.main.period=a.wantedperiod;
			}
			else
			{
				if (dist > 0)
				{
					a.tmpperiod-=a.portspeed<<2;
					a.main.period-=a.portspeed<<2;
					/* dist>0 slide up */
				}
				else
				{
					a.tmpperiod+=a.portspeed<<2;
					a.main.period+=a.portspeed<<2;
					/* dist<0 slide down */
				}
			}
		}
		else
		{
			a.tmpperiod=a.main.period;
		}
		a.ownper=1;
	}

	static function DoITVibrato(tick:Int, a:ModControl, dat:Int)
	{
		var q:Int;
		var temp=0;
		if (tick==0)
		{
			if (dat & 0x0f != 0) a.vibdepth = dat & 0xf;
			if (dat & 0xf0 != 0) a.vibspd = (dat & 0xf0) >> 2;
		}

		if (a.main.period == 0)
			return;
		q = (a.vibpos >> 2) & 0x1f;
		switch (a.wavecontrol&3)
		{
			case 0: /* sine */
				temp=VibratoTable[q];
			case 1: /* square wave */
				temp=255;
			case 2: /* ramp down */
				q<<=3;
				if (a.vibpos<0) q=255-q;
				temp=q;
			case 3: /* random */
				temp=getrandom(256);
		}

		temp *= a.vibdepth;
		temp>>=8;
		temp<<=2;
		if (a.vibpos>=0)
			a.main.period = a.tmpperiod + temp;
		else
			a.main.period = a.tmpperiod - temp;
		a.ownper=1;
		a.vibpos+=a.vibspd;
	}

	static function DoITEffectG(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		DoITToneSlide(tick, a, MUnitrk.UniGetByte());
		return 0;
	}

	static function DoITEffectH(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		DoITVibrato(tick, a, MUnitrk.UniGetByte());
		return 0;
	}

	static function DoITEffectI(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var on:Int;
		var off:Int;
		var inf = MUnitrk.UniGetByte();
		if (inf!=0)
		{
			a.s3mtronof = inf;
		}
		else
		{
			inf = a.s3mtronof;
			if (inf==0)
				return 0;
		}

		on=(inf>>4);
		off=(inf&0xf);
		a.s3mtremor%=(on+off);
		a.volume=(a.s3mtremor<on)?a.tmpvolume:0;
		a.ownvol = 1;
		a.s3mtremor++;
		return 0;
	}

	static function DoITEffectM(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		a.main.chanvol=MUnitrk.UniGetByte();
		if (a.main.chanvol > 64)
			a.main.chanvol = 64;
		else if (a.main.chanvol < 0)
			a.main.chanvol = 0;
		return 0;
	}

	static function DoITEffectN(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var lo:Int;
		var hi:Int;
		var inf = MUnitrk.UniGetByte();
		if (inf != 0)
		{
			a.chanvolslide = inf;
		}
		else
		{
			inf = a.chanvolslide;
		}
		lo = inf & 0xf;
		hi = inf >> 4;
		if (hi == 0)
		{
			a.main.chanvol -= lo;
		}
		else
		{
			if (lo==0)
			{
				a.main.chanvol += hi;
			}
			else
			{
				if (hi==0xf)
				{
					if (tick == 0) 
						a.main.chanvol -= lo;
				}
				else
				{
					if (lo==0xf)
					{
						if (tick == 0)
							a.main.chanvol += hi;
					}
				}
			}
		}

		if (a.main.chanvol < 0)
			a.main.chanvol = 0;
		else if (a.main.chanvol > 64)
			a.main.chanvol = 64;
		return 0;
	}

	static function DoITEffectP(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var lo:Int;
		var hi:Int;
		var pan:Int;
		var inf = MUnitrk.UniGetByte();
		if (inf!=0)
			a.pansspd = inf;
		else
			inf = a.pansspd;
		
		if (!mod.panflag)
			return 0;
		lo = inf & 0xf;
		hi = inf >> 4;
		pan = (a.main.panning == Defs.PAN_SURROUND)?Defs.PAN_CENTER:a.main.panning;
		if (hi == 0)
		{
			pan += lo << 2;
		}
		else
		{
			if (lo==0)
			{
				pan -= hi << 2;
			}
			else
			{
				if (hi==0xf)
				{
					if (tick == 0)
						pan += lo << 2;
				}
				else
				{
					if (lo==0xf)
					{
						if (tick == 0)
							pan -= hi << 2;
					}
				}
			}
		}
		
		a.main.panning = (pan<Defs.PAN_LEFT)?Defs.PAN_LEFT:(pan>Defs.PAN_RIGHT?Defs.PAN_RIGHT:pan);
		return 0;
	}

	static function DoITEffectT(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var temp:Int;
		var tempo = MUnitrk.UniGetByte();
		if (mod.patdly2 != 0)
			return 0;
		temp = mod.bpm;
		if (tempo & 0x10 != 0)
			temp += (tempo & 0x0f);
		else
			temp -= tempo;
		mod.bpm = (temp > 255)?255:(temp < 1?1:temp);
		return 0;
	}

	static function DoITEffectU(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var q:Int;
		var temp = 0;
		/* silence warning */

		var dat = MUnitrk.UniGetByte();
		if (tick==0)
		{
			if (dat & 0x0f != 0) a.vibdepth = dat & 0xf;
			if (dat & 0xf0 != 0) a.vibspd = (dat & 0xf0) >> 2;
		}

		if (a.main.period!=0)
		{
			q = (a.vibpos >> 2) & 0x1f;
			switch (a.wavecontrol&3)
			{
				case 0: /* sine */
					temp = VibratoTable[q];
				case 1: /* square wave */
					temp = 255;
				case 2: /* ramp down */
					q <<= 3;
					if (a.vibpos < 0) q = 255 - q;
					temp=q;
				case 3: /* random */
					temp=getrandom(256);
			}

			temp *= a.vibdepth;
			temp >>= 8;
			if (a.vibpos>=0)
				a.main.period = a.tmpperiod + temp;
			else
				a.main.period = a.tmpperiod - temp;
			a.ownper = 1;
			a.vibpos += a.vibspd;
		}

		return 0;
	}

	static function DoITEffectW(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var lo:Int;
		var hi:Int;
		var inf = MUnitrk.UniGetByte();
		if (inf!=0)
		{
			mod.globalslide = inf;
		}
		else
		{
			inf = mod.globalslide;
		}
		lo = inf & 0xf;
		hi = inf >> 4;
		if (lo == 0)
		{
			if (tick != 0)
				mod.volume += hi;
		}
		else
		{
			if (hi == 0)
			{
				if (tick != 0)
					mod.volume-= lo;
			}
			else
			{
				if (lo == 0xf)
				{
					if (tick == 0)
						mod.volume += hi;
				}
				else
				{
					if (hi == 0xf)
					{
						if (tick == 0)
							mod.volume-= lo;
					}
				}
			}
		}

		if (mod.volume < 0)
			mod.volume = 0;
		else if (mod.volume > 128)
			mod.volume=128;
		return 0;
	}

	static function DoITEffectY(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var q:Int;
		var temp = 0;
		/* silence warning */
		var dat=MUnitrk.UniGetByte();
		if (tick==0)
		{
			if (dat&0x0f!=0) a.panbdepth=(dat&0xf);
			if (dat&0xf0!=0) a.panbspd=(dat&0xf0)>>4;
		}

		if (mod.panflag)
		{
			q = a.panbpos;
			switch (a.panbwave)
			{
				case 0: /* sine */
					temp = PanbrelloTable[q];
				case 1: /* square wave */
					temp = (q < 0x80)?64:0;
				case 2: /* ramp down */
					q <<= 3;
					temp = q;
				case 3: /* random */
					temp = getrandom(256);
			}

			temp *= a.panbdepth;
			temp = Std.int(temp / 8) + mod.panning[channel];
			a.main.panning = (temp<Defs.PAN_LEFT)?Defs.PAN_LEFT:(temp>Defs.PAN_RIGHT?Defs.PAN_RIGHT:temp);
			a.panbpos += a.panbspd;
		}

		return 0;
	}

	/* Impulse/Scream Tracker Sxx effects.
		All Sxx effects share the same memory space. */
	static function DoITEffectS0(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var inf:Int;
		var c:Int;
		var dat = MUnitrk.UniGetByte();
		inf = dat & 0xf;
		c = dat >> 4;
		if (dat==0)
		{
			c = a.sseffect;
			inf = a.ssdata;
		}
		else
		{
			a.sseffect = c;
			a.ssdata = inf;
		}

		switch (c)
		{
			case Defs.SS_GLISSANDO: /* S1x set glissando voice */
				DoEEffects(tick, flags, a, mod, channel, 0x30 | inf);            
			case Defs.SS_FINETUNE: /* S2x set finetune */
				DoEEffects(tick, flags, a, mod, channel, 0x50|inf);
			case Defs.SS_VIBWAVE: /* S3x set vibrato waveform */
				DoEEffects(tick, flags, a, mod, channel, 0x40|inf);
			case Defs.SS_TREMWAVE: /* S4x set tremolo waveform */
				DoEEffects(tick, flags, a, mod, channel, 0x70|inf);
			case Defs.SS_PANWAVE: /* S5x panbrello */
				a.panbwave=inf;
			case Defs.SS_FRAMEDELAY: /* S6x delay x number of frames (patdly) */
				DoEEffects(tick, flags, a, mod, channel, 0xe0 | inf);
			case Defs.SS_S7EFFECTS: /* S7x instrument / NNA commands */
				DoNNAEffects(mod, a, inf);
			case Defs.SS_PANNING: /* S8x set panning position */
				DoEEffects(tick, flags, a, mod, channel, 0x80 | inf);
			case Defs.SS_SURROUND: /* S9x set surround sound */
				if (mod.panflag)
					a.main.panning = mod.panning[channel] = Defs.PAN_SURROUND;
			case Defs.SS_HIOFFSET: /* SAy set high order sample offset yxx00h */
				if (tick==0)
				{
					a.hioffset = inf << 16;
					a.main.start = a.hioffset | a.soffset;
					if ((a.main.s!=null)&&(a.main.start>a.main.s.length))
						a.main.start = (a.main.s.flags & (Defs.SF_LOOP | Defs.SF_BIDI) != 0)?a.main.s.loopstart:a.main.s.length;
				}
			case Defs.SS_PATLOOP: /* SBx pattern loop */
				DoEEffects(tick, flags, a, mod, channel, 0x60|inf);
			case Defs.SS_NOTECUT: /* SCx notecut */
				if (inf==0) inf = 1;
				DoEEffects(tick, flags, a, mod, channel, 0xC0|inf);
			case Defs.SS_NOTEDELAY: /* SDx notedelay */
				DoEEffects(tick, flags, a, mod, channel, 0xD0|inf);
			case Defs.SS_PATDELAY: /* SEx patterndelay */
				DoEEffects(tick, flags, a, mod, channel, 0xE0|inf);
		}
		return 0;
	}

	/*========== Impulse Tracker Volume/Pan Column effects */

	/*
	 * All volume/pan column effects share the same memory space.
	 */
	static function DoVolEffects(tick:Int, flags:Int, a:ModControl, mod:Module, channel:Int):Int
	{
		var c = MUnitrk.UniGetByte();
		var inf = MUnitrk.UniGetByte();
		if ((c == 0) && (inf == 0))
		{
			c=a.voleffect;
			inf=a.voldata;
		}
		else
		{
			a.voleffect=c;
			a.voldata=inf;
		}

		if (c != 0)
		{
			switch (c)
			{
				case Defs.VOL_VOLUME:
					if (tick==0)
					{
						if (inf>64) inf=64;
						a.tmpvolume=inf;
					}
				case Defs.VOL_PANNING:
					if (mod.panflag)
						a.main.panning=inf;
				case Defs.VOL_VOLSLIDE:
					DoS3MVolSlide(tick, flags, a, inf);
					return 1;
				case Defs.VOL_PITCHSLIDEDN:
					if (a.main.period!=0)
						DoS3MSlideDn(tick, a, inf);
				case Defs.VOL_PITCHSLIDEUP:
					if (a.main.period!=0)
						DoS3MSlideUp(tick, a, inf);
				case Defs.VOL_PORTAMENTO:
					DoITToneSlide(tick, a, inf);
				case Defs.VOL_VIBRATO:
					DoITVibrato(tick, a, inf);
			}
		}

		return 0;
	}

	static function ProcessEnvelope(aout:ModVoice /* ptr */, t:ENVPR /* ptr */ , v:Int):Int
	{
		if (t.flg & Defs.EF_ON!=0)
		{
			var a:Int;
			var b:Int;
			/* actual points in the envelope */
			var p:Int;
			/* the 'tick counter' - real point being played */

			a = t.a;
			b = t.b;
			p = t.p;
			/*
			* Sustain loop on one point (XM type).
			* Not processed if KEYOFF.
			* Don't move and don't interpolate when the point is reached
			*/
			if ((t.flg & Defs.EF_SUSTAIN)!=0 && t.susbeg == t.susend && ((aout.main.keyoff & Defs.KEY_OFF)==0 && p == t.env[t.susbeg].pos))
			{
				v = t.env[t.susbeg].val;
			}
			else
			{
				/*
				* All following situations will require interpolation between
				* two envelope points.
				*/

				/*
				* Sustain loop between two points (IT type).
				* Not processed if KEYOFF.
				*/
				/* if we were on a loop point, loop now */
				if ((t.flg & Defs.EF_SUSTAIN)!=0 && (aout.main.keyoff & Defs.KEY_OFF)==0 && a >= t.susend)
				{
					a = t.susbeg;
					b = (t.susbeg==t.susend)?a:a+1;
					p = t.env[a].pos;
					v = t.env[a].val;
				}
				else
				{
					/*
					* Regular loop.
					* Be sure to correctly handle single point loops.
					*/
					if ((t.flg & Defs.EF_LOOP)!=0 && a >= t.end)
					{
						a = t.beg;
						b = t.beg == t.end ? a : a + 1;
						p = t.env[a].pos;
						v = t.env[a].val;
					}
					else
					{
						/*
						* Non looping situations.
						*/
						if (a != b)
							v = InterpolateEnv(p, t.env[a], t.env[b]);
						else
							v = t.env[a].val;
					}
				}
				/*
				* Start to fade if the volume envelope is finished.
				*/
				if (p >= t.env[t.pts - 1].pos)
				{
					if (t.flg & Defs.EF_VOLENV!=0)
					{
						aout.main.keyoff |= Defs.KEY_FADE;
						if (v == 0)
							aout.main.fadevol = 0;
					}
				}
				else
				{
					p++;
					/* did pointer reach point b? */
					if (p >= t.env[b].pos)
						a = b++;
					/* shift points a and b */
				}

				t.a = a;
				t.b = b;
				t.p = p;
			}
		}

		return v;
	}

	static function StartEnvelope(t:ENVPR, flg:Int, pts:Int, susbeg:Int, susend:Int, beg:Int, end:Int, p:Array<EnvelopePoint>, keyoff:Int):Int
	{
		t.flg=flg;
		t.pts=pts;
		t.susbeg=susbeg;
		t.susend=susend;
		t.beg=beg;
		t.end=end;
		t.env=p;
		t.p=0;
		t.a=0;
		t.b = ((t.flg & Defs.EF_SUSTAIN != 0) && ((keyoff & Defs.KEY_OFF) == 0))?0:1;
		/* Imago Orpheus sometimes stores an extra initial point in the envelope */
		if ((t.pts >= 2) && (t.env[0].pos == t.env[1].pos))
		{
			t.a++;
			t.b++;
		}

		/* Fit in the envelope, still */
		if (t.a >= t.pts)
			t.a = t.pts - 1;
		if (t.b >= t.pts)
			t.b = t.pts-1;
		return t.env[t.a].val;
	}

	/* Handles effects */
	static function pt_EffectsPass1(mod:Module)
	{
		var channel:Int;
		var a:ModControl;
		// ptr
		var aout:ModVoice;
		// ptr
		var explicitslides:Bool;
		Profiler.ENTER();
		for (channel in 0 ... mod.numchn)
		{
			a=mod.control[channel];
			if ((aout=a.slave)!=null)
			{
				a.main.fadevol=aout.main.fadevol;
				a.main.period=aout.main.period;
				if (a.main.kick==Defs.KICK_KEYOFF)
					a.main.keyoff=aout.main.keyoff;
			}

			if (a.row==0) continue;
			MUnitrk.UniSetRow(a.row);
			a.ownper=a.ownvol=0;
			explicitslides = (pt_playeffects(mod, channel, a)!=0);
			/* continue volume slide if necessary for XM and IT */
			if (mod.flags&Defs.UF_BGSLIDES!=0)
			{
				if (!explicitslides && a.sliding)
					DoS3MVolSlide(mod.vbtick, mod.flags, a, 0);
				else if (a.tmpvolume!=0)
					a.sliding = explicitslides;
			}

			if (a.ownper==0)
				a.main.period=a.tmpperiod;
			if (a.ownvol==0)
				a.volume=a.tmpvolume;
			if (a.main.s!=null)
			{
				if (a.main.i!=null)
					a.main.outvolume = (a.volume * a.main.s.globvol * a.main.i.globvol) >> 10;
				else
					a.main.outvolume = (a.volume * a.main.s.globvol) >> 4;
				
				if (a.main.outvolume>256)
					a.main.outvolume = 256;
				else if (a.main.outvolume<0)
					a.main.outvolume=0;
			}
		}

		Profiler.LEAVE();
	}

	static function DoNNAEffects(mod:Module, a:ModControl, dat:Int)
	{
		//int t;
		var aout:ModVoice;
		dat&=0xf;
		//aout=(a->slave)?a->slave:NULL;
		aout=a.slave;
		// that's smart
		switch (dat)
		{
			case 0x0: /* past note cut */
				for (t in 0 ... MDriver.md_sngchn)
					if (mod.voice[t].master == a)
						mod.voice[t].main.fadevol = 0;
			case 0x1: /* past note off */
				for (t in 0 ... MDriver.md_sngchn)
				{
					if (mod.voice[t].master==a)
					{
						mod.voice[t].main.keyoff|=Defs.KEY_OFF;
						if ((0 == (mod.voice[t].venv.flg & Defs.EF_ON)) || (mod.voice[t].venv.flg & Defs.EF_LOOP) != 0)
							mod.voice[t].main.keyoff=Defs.KEY_KILL;
					}
				}
			case 0x2: /* past note fade */
				for (t in 0 ... MDriver.md_sngchn)
					if (mod.voice[t].master==a)
						mod.voice[t].main.keyoff|=Defs.KEY_FADE;
			case 0x3: /* set NNA note cut */
				a.main.nna=(a.main.nna&~Defs.NNA_MASK)|Defs.NNA_CUT;
			case 0x4: /* set NNA note continue */
				a.main.nna=(a.main.nna&~Defs.NNA_MASK)|Defs.NNA_CONTINUE;
			case 0x5: /* set NNA note off */
				a.main.nna=(a.main.nna&~Defs.NNA_MASK)|Defs.NNA_OFF;
			case 0x6: /* set NNA note fade */
				a.main.nna=(a.main.nna&~Defs.NNA_MASK)|Defs.NNA_FADE;
			case 0x7: /* disable volume envelope */
				if (aout!=null)
					aout.main.volflg&=~Defs.EF_ON;
			case 0x8: /* enable volume envelope  */
				if (aout!=null)
					aout.main.volflg|=Defs.EF_ON;
			case 0x9: /* disable panning envelope */
				if (aout!=null)
					aout.main.panflg &= ~Defs.EF_ON;
			case 0xa: /* enable panning envelope */
				if (aout!=null)
					aout.main.panflg |= Defs.EF_ON;
			case 0xb: /* disable pitch envelope */
				if (aout!=null)
					aout.main.pitflg &= ~Defs.EF_ON;
			case 0xc: /* enable pitch envelope */
				if (aout!=null)
					aout.main.pitflg |= Defs.EF_ON;
		}
	}

	static function pt_EffectsPass2(mod:Module)
	{
		var channel:Int;
		var a:ModControl;
		var c:Int;
		Profiler.ENTER();
		for (channel in 0 ... mod.numchn)
		{
			a=mod.control[channel];
			if (a.row == 0)
				continue;
			MUnitrk.UniSetRow(a.row);
			while ((c = MUnitrk.UniGetByte()) != 0)
			{
				if (c==Defs.UNI_ITEFFECTS0)
				{
					c = MUnitrk.UniGetByte();
					if ((c >> 4) == Defs.SS_S7EFFECTS)
						DoNNAEffects(mod, a, c&0xf);
				}
				else
				{
					MUnitrk.UniSkipOpcode();
				}
			}
		}

		Profiler.LEAVE();
	}

	static function pt_UpdateVoices(mod:Module, max_volume:Int)
	{
		var envpan:Int;
		var envvol:Int;
		var envpit:Int;
		var channel:Int;
		var playperiod:Int;
		var vibval:Int;
		var vibdpt:Int;
		var tmpvol:Int;
		var aout:ModVoice;
		// ptr
		var i:Instrument;
		// ptr
		var s:Sample;
		// ptr
		Profiler.ENTER();
		mod.totalchn = mod.realchn = 0;
		for (channel in 0 ... MDriver.md_sngchn)
		{
			aout=mod.voice[channel];
			if (aout==null) continue;
			// ???
			i=aout.main.i;
			s=aout.main.s;
			if (s==null || s.length==0) continue;
			if (aout.main.period<40)
				aout.main.period = 40;
			else if (aout.main.period > 50000)
				aout.main.period=50000;
			if ((aout.main.kick == Defs.KICK_NOTE) || (aout.main.kick == Defs.KICK_KEYOFF))
			{
				TrackerEventDispatcher.dispatchEventDelay(new TrackerNoteEvent(aout.main),pf.sngtime-pf.audiobufferstart);
				Profiler.LEAVE();
				// exclude diagnostic gfx
				MDriver.Voice_Play_internal(channel,s,(aout.main.start==-1)?((s.flags&Defs.SF_UST_LOOP)!=0?s.loopstart:0):aout.main.start);
				Profiler.ENTER();
				aout.main.fadevol=32768;
				aout.aswppos=0;
			}

			envvol = 256;
			envpan = Defs.PAN_CENTER;
			envpit = 32;
			if (i!=null && ((aout.main.kick==Defs.KICK_NOTE)||(aout.main.kick==Defs.KICK_ENV)))
			{
				if (aout.main.volflg & Defs.EF_ON!=0)
					envvol = StartEnvelope(aout.venv,aout.main.volflg,
						i.vol_env.pts,i.vol_env.susbeg,i.vol_env.susend,
						i.vol_env.beg,i.vol_env.end,i.vol_env.env,aout.main.keyoff);
				if (aout.main.panflg & Defs.EF_ON!=0)
					envpan = StartEnvelope(aout.penv,aout.main.panflg,
						i.pan_env.pts,i.pan_env.susbeg,i.pan_env.susend,
						i.pan_env.beg,i.pan_env.end,i.pan_env.env,aout.main.keyoff);
				if (aout.main.pitflg & Defs.EF_ON!=0)
					envpit = StartEnvelope(aout.cenv,aout.main.pitflg,
						i.pit_env.pts,i.pit_env.susbeg,i.pit_env.susend,
						i.pit_env.beg,i.pit_env.end,i.pit_env.env,aout.main.keyoff);
				if (aout.cenv.flg & Defs.EF_ON != 0)
					aout.masterperiod = GetPeriod(mod.flags, aout.main.note << 1, aout.master.speed);
				// cast
			}
			else
			{
				if (aout.main.volflg & Defs.EF_ON!=0)
					envvol = ProcessEnvelope(aout, aout.venv, 256);
				if (aout.main.panflg & Defs.EF_ON!=0)
					envpan = ProcessEnvelope(aout, aout.penv, Defs.PAN_CENTER);
				if (aout.main.pitflg & Defs.EF_ON!=0)
					envpit = ProcessEnvelope(aout, aout.cenv, 32);
			}

			if (aout.main.kick == Defs.KICK_NOTE)
			{
				aout.main.kick_flag = true;
			}

			aout.main.kick = Defs.KICK_ABSENT;
			tmpvol = aout.main.fadevol;
			/* max 32768 */
			tmpvol *= aout.main.chanvol;
			/* * max 64 */
			tmpvol *= aout.main.outvolume;
			/* * max 256 */
			tmpvol=Std.int(tmpvol / (256 * 64));
			/* tmpvol is max 32768 again */
			aout.totalvol = tmpvol >> 2;
			/* used to determine samplevolume */
			tmpvol *= envvol;
			/* * max 256 */
			tmpvol *= mod.volume;
			/* * max 128 */
			tmpvol = Std.int(tmpvol/(128 * 256 * 128));
			/* fade out */
			if (mod.sngpos>=mod.numpos)
				tmpvol = 0;
			else
				tmpvol = Std.int((tmpvol * max_volume) / 128);
			
			if ((aout.masterchn != -1) && mod.control[aout.masterchn].muted)
			{
				MDriver.Voice_SetVolume_internal(channel, 0); 
			}
			else
			{
				MDriver.Voice_SetVolume_internal(channel,tmpvol);
				if ((tmpvol != 0) && (aout.master != null) && (aout.master.slave == aout))
					mod.realchn++;
				mod.totalchn++;
			}

			if (aout.main.panning==Defs.PAN_SURROUND)
			{
				MDriver.Voice_SetPanning_internal(channel,Defs.PAN_SURROUND);
			}
			else
			{
				if ((mod.panflag)&&(aout.penv.flg & Defs.EF_ON)!=0)
				{
					MDriver.Voice_SetPanning_internal(channel,DoPan(envpan,aout.main.panning));
				}
				else
				{
					MDriver.Voice_SetPanning_internal(channel,aout.main.panning);
				}
			}

			if (aout.main.period!=0 && s.vibdepth!=0)
			{
				switch (s.vibtype)
				{
					case 0:
						vibval = avibtab[s.avibpos & 127];
						if (aout.avibpos & 0x80 != 0) vibval = -vibval;
					case 1:
						vibval=64;
						if (aout.avibpos & 0x80 != 0) vibval = -vibval;
					case 2:
						vibval = 63 - (((aout.avibpos + 128) & 255) >> 1);
					default:
						vibval = (((aout.avibpos + 128) & 255) >> 1) - 64;
				}
			}
			else
			{
				vibval = 0;
			}
			
			if (s.vibflags & Defs.AV_IT!=0)
			{
				if ((aout.aswppos >> 8) < s.vibdepth)
				{
					aout.aswppos += s.vibsweep;
					vibdpt = aout.aswppos;
				}
				else
				{
					vibdpt = s.vibdepth << 8;
				}
				vibval=(vibval*vibdpt)>>16;
				if (aout.mflag)
				{
					if ((mod.flags & Defs.UF_LINEAR) == 0) vibval >>= 1;
					aout.main.period-=vibval;
				}
			}
			else
			{
				/* do XM style auto-vibrato */
				if ((aout.main.keyoff & Defs.KEY_OFF)==0)
				{
					if (aout.aswppos<s.vibsweep)
					{
						vibdpt = Std.int((aout.aswppos * s.vibdepth) / s.vibsweep);
						aout.aswppos++;
					}
					else
					{
						vibdpt=s.vibdepth;
					}
				}
				else
				{
					/* keyoff . depth becomes 0 if final depth wasn't reached or
					stays at final level if depth WAS reached */
					if (aout.aswppos>=s.vibsweep)
						vibdpt=s.vibdepth;
					else
						vibdpt=0;
				}
				vibval=(vibval*vibdpt)>>8;
				aout.main.period-=vibval;
			}

			/* update vibrato position */
			aout.avibpos=(aout.avibpos+s.vibrate)&0xff;

			/* process pitch envelope */
			playperiod=aout.main.period;

			if ((aout.main.pitflg & Defs.EF_ON) != 0 && (envpit != 32))
			{
				var p1:Int; // long

				envpit-=32;
				if ((aout.main.note<<1)+envpit<=0) envpit=-(aout.main.note<<1);

				p1=GetPeriod(mod.flags, (aout.main.note<<1)+envpit,	// cast
				aout.master.speed)-aout.masterperiod;
				if (p1 > 0)
				{
					if ((playperiod + p1) <= playperiod)
					{ 	// cast
						p1=0;
						aout.main.keyoff|=Defs.KEY_OFF;
					}
				}
				else if (p1 < 0)
				{
					if ((playperiod + p1) >= playperiod)
					{	// cast
						p1=0;
						aout.main.keyoff|=Defs.KEY_OFF;
					}
				}
				playperiod+=p1;
			}

			if (aout.main.fadevol == 0)
			{ /* check for a dead note (fadevol=0) */
				MDriver.Voice_Stop_internal(channel);
				mod.totalchn--;
				if ((tmpvol != 0) && (aout.master != null) && (aout.master.slave == aout))
					mod.realchn--;
			}
			else
			{
				MDriver.Voice_SetFrequency_internal(channel,
				getfrequency(mod.flags,playperiod));

				/* if keyfade, start substracting fadeoutspeed from fadevol: */
				if ((i != null) && (aout.main.keyoff & Defs.KEY_FADE) != 0)
				{
					if (aout.main.fadevol>=i.volfade)
						aout.main.fadevol-=i.volfade;
					else
						aout.main.fadevol=0;
				}
			}

			MDriver.md_bpm=mod.bpm+mod.relspd;
			if (MDriver.md_bpm<32)
				MDriver.md_bpm=32;
			else if (((mod.flags & Defs.UF_HIGHBPM) == 0) && MDriver.md_bpm > 255)
				MDriver.md_bpm=255;
		}
		Profiler.LEAVE();
	}


	/* NNA management */
	static function pt_NNA(mod:Module)
	{
		var a:ModControl;
		
		Profiler.ENTER();
		for (channel in 0 ... mod.numchn)
		{
			a = mod.control[channel];
			
			if (a.main.kick == Defs.KICK_NOTE)
			{
				var kill=false;

				if (a.slave != null)
				{
					var aout=a.slave;

					if (aout.main.nna & Defs.NNA_MASK != 0)
					{
						/* Make sure the old ModVoice channel knows it has no
						master now ! */
						a.slave=null;
						/* assume the channel is taken by NNA */
						aout.mflag=false;

						switch (aout.main.nna)
						{
							case Defs.NNA_CONTINUE: /* continue note, do nothing */
							case Defs.NNA_OFF: /* note off */
								aout.main.keyoff|=Defs.KEY_OFF;
								if ((0==(aout.main.volflg & Defs.EF_ON))||
								(aout.main.volflg & Defs.EF_LOOP)!=0)
								aout.main.keyoff=Defs.KEY_KILL;
							case Defs.NNA_FADE:
								aout.main.keyoff |= Defs.KEY_FADE;
						}
					}
				}

				if (a.dct != Defs.DCT_OFF)
				{

					for (t in 0 ... MDriver.md_sngchn)
					{
						if ((!MDriver.Voice_Stopped_internal(t))&&
							(mod.voice[t].masterchn==channel)&&
							(a.main.sample == mod.voice[t].main.sample))
						{
							kill=false;
							switch (a.dct)
							{
								case Defs.DCT_NOTE:
									if (a.main.note==mod.voice[t].main.note)
									kill=true;
								case Defs.DCT_SAMPLE:
									if (a.main.handle==mod.voice[t].main.handle)
									kill=true;
								case Defs.DCT_INST:
									kill=true;
							}
							if (kill)
							{
								switch (a.dca)
								{
									case Defs.DCA_CUT:
										mod.voice[t].main.fadevol = 0;
									case Defs.DCA_OFF:
										mod.voice[t].main.keyoff |= Defs.KEY_OFF;
										if ((0 == (mod.voice[t].main.volflg & Defs.EF_ON)) ||
											(mod.voice[t].main.volflg & Defs.EF_LOOP) != 0)
												mod.voice[t].main.keyoff = Defs.KEY_KILL;
									case Defs.DCA_FADE:
										mod.voice[t].main.keyoff |= Defs.KEY_FADE;
								}
							}
						}
					}
				}
			} /* if (a->main.kick==KICK_NOTE) */
		}

		Profiler.LEAVE();
	}

	/* Setup module and NNA voices */
	static function pt_SetupVoices(mod:Module) {
		var channel:Int;
		var a:ModControl;
		var aout:ModVoice;
		Profiler.ENTER();
		
		for (channel in 0 ... mod.numchn)
		{
			a=mod.control[channel];

			if (a.main.notedelay!=0) continue;
			if (a.main.kick == Defs.KICK_NOTE)
			{
				/* if no channel was cut above, find an empty or quiet channel
				here */
				if (mod.flags & Defs.UF_NNA != 0)
				{
					if (a.slave == null)
					{
						var newchn:Int;

						if ((newchn=MP_FindEmptyChannel(mod))!=-1)
							a.slave=mod.voice[a.slavechn=newchn];
					}
				}
				else
				{
					a.slave=mod.voice[a.slavechn=channel];
				}

				/* assign parts of ModVoice only done for a KICK_NOTE */
				if ((aout = a.slave) != null)
				{
					if (aout.mflag && aout.master != null)
						aout.master.slave=null;
					aout.master=a;
					a.slave=aout;
					aout.masterchn=channel;
					aout.mflag=true;
				}
			}
			else
			{
				aout=a.slave;
			}

			if (aout != null)
			{
				a.main.clone(aout.main);
			}
			a.main.kick = Defs.KICK_ABSENT;
		}

		Profiler.LEAVE();
	}

	/* Handles new notes or instruments */
	static function pt_Notes(mod:Module)
	{
		var channel:Int;
		var a:ModControl;
		var c:Int;
		var inst:Int;
		var tr:Int;
		var funky:Int;   /* funky is set to indicate note or instrument change */

		for (channel in 0 ... mod.numchn)
		{
			a = mod.control[channel];
			
			if (mod.sngpos >= mod.numpos)
			{
				tr=mod.numtrk;
				mod.numrow=0;
			}
			else
			{
				tr = mod.patterns[(mod.positions[mod.sngpos] * mod.numchn) + channel];
				mod.numrow = mod.pattrows[mod.positions[mod.sngpos]];
			}

			a.row=(tr<mod.numtrk)?MUnitrk.UniFindRow(mod.tracks[tr],mod.patpos):0;
			a.newsamp=0;
			if (mod.vbtick == 0)
				a.main.notedelay=0;

			if (a.row == 0) continue;
			MUnitrk.UniSetRow(a.row);
			funky=0;

			while ((c = MUnitrk.UniGetByte()) != 0)
			{
				switch (c)
				{
					case Defs.UNI_NOTE:
						funky|=1;
						a.oldnote=a.anote; a.anote=MUnitrk.UniGetByte();
						a.main.kick =Defs.KICK_NOTE;
						a.main.start=-1;
						a.sliding=false;

						/* retrig tremolo and vibrato waves ? */
						if ((a.wavecontrol & 0x80)==0) a.trmpos=0;
						if ((a.wavecontrol & 0x08)==0) a.vibpos=0;
						if (a.panbwave==0) a.panbpos=0;
					case Defs.UNI_INSTRUMENT:
						inst=MUnitrk.UniGetByte();
						if (inst<mod.numins) { // safety valve
							funky|=2;
							a.main.i=(mod.flags&Defs.UF_INST!=0)?mod.instruments[inst]:null;
							a.retrig=0;
							a.s3mtremor=0;
							a.ultoffset=0;
							a.main.sample=inst;
						}
					default:
						MUnitrk.UniSkipOpcode();
				}
			}

			if (funky != 0)
			{
				var i:Instrument;
				var s:Sample;

				if ((i = a.main.i) != null)
				{
					if (i.samplenumber[a.anote] >= mod.numsmp)
						continue;
					s = mod.samples[i.samplenumber[a.anote]];
					a.main.note=i.samplenote[a.anote];
				}
				else
				{
					a.main.note=a.anote;
					s = mod.samples[a.main.sample];
				}

				if (a.main.s != s)
				{
					a.main.s=s;
					a.newsamp=a.main.period;
				}

				/* channel or instrument determined panning ? */
				a.main.panning=mod.panning[channel];
				if (s.flags & Defs.SF_OWNPAN!=0)
					a.main.panning=s.panning;
				else if ((i!=null)&&(i.flags & Defs.IF_OWNPAN!=0))
					a.main.panning=i.panning;

				a.main.handle=s.handle;
				a.speed=s.speed;

				if (i != null)
				{
					if ((mod.panflag)&&(i.flags & Defs.IF_PITCHPAN)!=0
						&&(a.main.panning != Defs.PAN_SURROUND))
					{
						a.main.panning += Std.int(((a.anote-i.pitpancenter) * i.pitpansep) / 8);
						if (a.main.panning<Defs.PAN_LEFT)
							a.main.panning=Defs.PAN_LEFT;
						else if (a.main.panning>Defs.PAN_RIGHT)
							a.main.panning=Defs.PAN_RIGHT;
					}
					a.main.pitflg=i.pit_env.flg;
					a.main.volflg=i.vol_env.flg;
					a.main.panflg=i.pan_env.flg;
					a.main.nna=i.nnatype;
					a.dca=i.dca;
					a.dct=i.dct;
				}
				else
				{
					a.main.pitflg=a.main.volflg=a.main.panflg=0;
					a.main.nna=a.dca=0;
					a.dct=Defs.DCT_OFF;
				}

				if (funky&2!=0) /* instrument change */
				{
					/* IT random volume variations: 0:8 bit fixed, and one bit for
					sign. */
					a.volume=a.tmpvolume=s.volume;
					if ((s != null) && (i != null))
					{
						if (i.rvolvar != 0)
						{
							a.volume=a.tmpvolume=s.volume+
							// castit? ((s.volume*((Int)i.rvolvar*(Int)getrandom(512)
							Std.int((s.volume*(i.rvolvar*getrandom(512)))/25600);
							if (a.volume<0)
								a.volume=a.tmpvolume=0;
							else if (a.volume>64)
								a.volume=a.tmpvolume=64;
						}
						// casteja
						if ((mod.panflag) && (a.main.panning != Defs.PAN_SURROUND))
						{
							a.main.panning+=Std.int((a.main.panning*(i.rpanvar*getrandom(512)))/25600);
							if (a.main.panning<Defs.PAN_LEFT)
								a.main.panning=Defs.PAN_LEFT;
							else if (a.main.panning>Defs.PAN_RIGHT)
								a.main.panning=Defs.PAN_RIGHT;
						}
					}
				}
				a.wantedperiod=a.tmpperiod=
				GetPeriod(mod.flags, /*(Int)*/ a.main.note<<1,a.speed);
				a.main.keyoff=Defs.KEY_KICK;
				//trace("period="+a.wantedperiod);
			}
		}
	}

	public static function Player_Stop_internal()
	{
		//stopFlashAudio();
		if (MDriver.md_sfxchn == 0)
			MDriver.MikMod_DisableOutput_internal();
		if (pf != null)
			pf.forbid=true;
		pf=null;
	}

	public static function Player_Exit_internal(mod:Module)
	{
		if (mod==null) return;

		/* Stop playback if necessary */
		if (mod == pf)
		{
			Player_Stop_internal();
			pf = null;
		}

		/*if (mod.control!=null)
		free(mod.control);
		if (mod.voice)
		free(mod.voice); */
		mod.control=null;
		mod.voice=null;
	}

	// call this when starting to fill a new audio buffer

	public static function audioBufferStart()
	{
		if (pf != null)
			pf.audiobufferstart = pf.sngtime;
	}

	public static function Player_HandleTick()
	{
		var channel:Int;
		var max_volume:Int;

		//trace("pf.forbid="+(pf==null?true:pf.forbid)+" of="+MLoader.of+" pf==of: "+(pf==MLoader.of)+" pf.name="+(pf==null?"-":pf.songname)+" of.name="+(MLoader.of==null?"-":MLoader.of.songname));
		if (pf == null || pf.forbid || pf.sngpos >= pf.numpos)
			return;

		Profiler.ENTER();

		/* update time counter (sngtime is in milliseconds (in fact 2^-10)) */
		pf.sngremainder += (1 << 9) * 5; /* thus 2.5*(1<<10), since fps=0.4xtempo */
		pf.sngtime += Std.int(pf.sngremainder / pf.bpm);
		pf.sngremainder %= pf.bpm;

		if (++pf.vbtick >= pf.sngspd)
		{
			if (pf.pat_repcrazy!=0) 
				pf.pat_repcrazy=0; /* play 2 times row 0 */
			else
				pf.patpos++;
			pf.vbtick=0;

			/* process pattern-delay. pf.patdly2 is the counter and pf.patdly is
			the command memory. */
			if (pf.patdly!=0)
			{
				pf.patdly2 = pf.patdly;
				pf.patdly = 0;
			}
			if (pf.patdly2 != 0)
			{
				/* patterndelay active */
				if (--pf.patdly2 != 0)
					/* so turn back pf.patpos by 1 */
					if (pf.patpos != 0)
						pf.patpos--;
			}

			/* do we have to get a new patternpointer ? (when pf.patpos reaches the
			pattern size, or when a patternbreak is active) */
			if (((pf.patpos >= pf.numrow) && (pf.numrow > 0)) && (pf.posjmp == 0))
				pf.posjmp=3;

			if (pf.posjmp != 0)
			{
				pf.patpos=(pf.numrow!=0?(pf.patbrk%pf.numrow):0);
				pf.pat_repcrazy=0;
				pf.sngpos+=(pf.posjmp-2);

				for (channel in 0 ... pf.numchn)
					pf.control[channel].pat_reppos=-1;

				pf.patbrk=pf.posjmp=0;
				/* handle the "---" (end of song) pattern since it can occur
				*inside* the module in some formats */
				if ((pf.sngpos >= pf.numpos) || (pf.positions[pf.sngpos] == Defs.LAST_PATTERN))
				{
					if (!pf.wrap)
					{
						TrackerEventDispatcher.dispatchEvent(new TrackerPlayPosEvent(pf.sngpos,pf.numpos,true));
						return;
					}
					if ((pf.sngpos = pf.reppos) == 0)
					{
						pf.volume = pf.initvolume > 128?128:pf.initvolume;
						if(pf.initspeed!=0)
							pf.sngspd = pf.initspeed < 32?pf.initspeed:32;
						else
							pf.sngspd = 6;
						pf.bpm = pf.inittempo < 32?32:pf.inittempo;
					}
				}
				if (pf.sngpos < 0)
					pf.sngpos=pf.numpos-1;
				TrackerEventDispatcher.dispatchEvent(new TrackerPlayPosEvent(pf.sngpos,pf.numpos,false));
			}
			
			if (pf.patdly2 == 0)
				pt_Notes(pf);
		}

		/* Fade global volume if enabled and we're playing the last pattern */
		if (((pf.sngpos == pf.numpos - 1) || (pf.positions[pf.sngpos + 1] == Defs.LAST_PATTERN)) && (pf.fadeout))
		{
			max_volume = pf.numrow != 0?Std.int(((pf.numrow - pf.patpos) * 128) / pf.numrow):0;
		}
		else
		{
			max_volume = 128;
		}
		
		pt_EffectsPass1(pf);
		if (pf.flags & Defs.UF_NNA != 0)
			pt_NNA(pf);
		pt_SetupVoices(pf);
		pt_EffectsPass2(pf);
		/* now set up the actual hardware channel playback information */
		pt_UpdateVoices(pf, max_volume);
		Profiler.LEAVE();
	}

	public static function Player_Init_internal(mod:Module)
	{
		for (t in 0 ... mod.numchn)
		{
			mod.control[t].main.chanvol=mod.chanvol[t];
			mod.control[t].main.panning=mod.panning[t];
		}

		mod.sngtime=0;
		mod.sngremainder=0;
		mod.pat_repcrazy=0;
		mod.sngpos=0;
		if(mod.initspeed!=0)
			mod.sngspd = mod.initspeed < 32?mod.initspeed:32;
		else
			mod.sngspd=6;
		mod.volume=mod.initvolume>128?128:mod.initvolume;
		mod.vbtick=mod.sngspd;
		mod.patdly=0;
		mod.patdly2=0;
		mod.bpm=mod.inittempo<32?32:mod.inittempo;
		mod.realchn=0;
		mod.patpos=0;
		mod.posjmp=2;
		/* make sure the player fetches the first note */
				mod.numrow=-1;
		mod.patbrk=0;
	}
}