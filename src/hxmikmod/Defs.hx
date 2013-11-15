/**
 *
 * hxMikMod sound library
 * Copyright (C) 2011 Jouko Pynnönen <jouko@iki.fi>
 *             
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
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
// Various numerical constants

class Defs
{
	
	/* Sample playback should not be interrupted */
	inline inline public static var SFX_CRITICAL=1;
	
	/* Sample format [loading and in-memory] flags: */
	inline public static var SF_16BITS=0x0001;
	inline public static var SF_STEREO=0x0002;
	inline public static var SF_SIGNED=0x0004;
	inline public static var SF_BIG_ENDIAN=0x0008;
	inline public static var SF_DELTA=0x0010;
	inline public static var SF_ITPACKED=0x0020;
	inline public static var SF_FORMATMASK=0x003F;
	
	/* General Playback flags */
	inline public static var SF_LOOP=0x0100;
	inline public static var SF_BIDI=0x0200;
	inline public static var SF_REVERSE=0x0400;
	inline public static var SF_SUSTAIN=0x0800;
	inline public static var SF_PLAYBACKMASK=0x0C00;
	
	/* Module-only Playback Flags */
	inline public static var SF_OWNPAN=0x1000;
	inline public static var SF_UST_LOOP=0x2000;
	inline public static var SF_EXTRAPLAYBACKMASK=0x3000;
	
	/* Panning constants */
	inline public static var PAN_LEFT=0;
	inline public static var PAN_HALFLEFT=96;
	// j
	inline public static var PAN_CENTER=128;
	inline public static var PAN_HALFRIGHT=160;
	// j
	inline public static var PAN_RIGHT=255;
	inline public static var PAN_SURROUND=512;
	inline public static var LAST_PATTERN=-1;
	inline public static var POS_NONE=-2;
	
	/* no loop position defined */
	// enum...
	inline public static var UNI_NOTE = 1;
	inline public static var UNI_INSTRUMENT=2;
	
	/* Protracker effects */
	inline public static var UNI_PTEFFECT0=3;
	
	/* arpeggio */
	inline public static var UNI_PTEFFECT1=4;
	
	/* porta up */
	inline public static var UNI_PTEFFECT2=5;
	
	/* porta down */
	inline public static var UNI_PTEFFECT3=6;
	
	/* porta to note */
	inline public static var UNI_PTEFFECT4=7;
	
	/* vibrato */
	inline public static var UNI_PTEFFECT5=8;
	
	/* dual effect 3+A */
	inline public static var UNI_PTEFFECT6=9;
	
	/* dual effect 4+A */
	inline public static var UNI_PTEFFECT7=10;
	
	/* tremolo */
	inline public static var UNI_PTEFFECT8=11;
	
	/* pan */
	inline public static var UNI_PTEFFECT9=12;
	
	/* sample offset */
	inline public static var UNI_PTEFFECTA=13;
	
	/* volume slide */
	inline public static var UNI_PTEFFECTB=14;
	
	/* pattern jump */
	inline public static var UNI_PTEFFECTC=15;
	
	/* set volume */
	inline public static var UNI_PTEFFECTD=16;
	
	/* pattern break */
	inline public static var UNI_PTEFFECTE=17;
	
	/* extended effects */
	inline public static var UNI_PTEFFECTF=18;
	
	/* set speed */
	
	/* Scream Tracker effects */
	inline public static var UNI_S3MEFFECTA=19;
	
	/* set speed */
	inline public static var UNI_S3MEFFECTD=20;
	
	/* volume slide */
	inline public static var UNI_S3MEFFECTE=21;
	
	/* porta down */
	inline public static var UNI_S3MEFFECTF=22;
	
	/* porta up */
	inline public static var UNI_S3MEFFECTI=23;
	
	/* tremor */
	inline public static var UNI_S3MEFFECTQ=24;
	
	/* retrig */
	inline public static var UNI_S3MEFFECTR=25;
	
	/* tremolo */
	inline public static var UNI_S3MEFFECTT=26;
	
	/* set tempo */
	inline public static var UNI_S3MEFFECTU=27;
	
	/* fine vibrato */
	inline public static var UNI_KEYOFF=28;
	
	/* note off */
	
	/* Fast Tracker effects */
	inline public static var UNI_KEYFADE=29;
	
	/* note fade */
	inline public static var UNI_VOLEFFECTS=30;
	
	/* volume column effects */
	inline public static var UNI_XMEFFECT4=31;
	
	/* vibrato */
	inline public static var UNI_XMEFFECT6=32;
	
	/* dual effect 4+A */
	inline public static var UNI_XMEFFECTA=33;
	
	/* volume slide */
	inline public static var UNI_XMEFFECTE1=34;
	
	/* fine porta up */
	inline public static var UNI_XMEFFECTE2=35;
	
	/* fine porta down */
	inline public static var UNI_XMEFFECTEA=36;
	
	/* fine volume slide up */
	inline public static var UNI_XMEFFECTEB=37;
	
	/* fine volume slide down */
	inline public static var UNI_XMEFFECTG=38;
	
	/* set global volume */
	inline public static var UNI_XMEFFECTH=39;
	
	/* global volume slide */
	inline public static var UNI_XMEFFECTL=40;
	
	/* set envelope position */
	inline public static var UNI_XMEFFECTP=41;
	
	/* pan slide */
	inline public static var UNI_XMEFFECTX1=42;
	
	/* extra fine porta up */
	inline public static var UNI_XMEFFECTX2=43;
	
	/* extra fine porta down */
	
	/* Impulse Tracker effects */
	inline public static var UNI_ITEFFECTG=44;
	
	/* porta to note */
	inline public static var UNI_ITEFFECTH=45;
	
	/* vibrato */
	inline public static var UNI_ITEFFECTI=46;
	
	/* tremor (xy not incremented) */
	inline public static var UNI_ITEFFECTM=47;
	
	/* set channel volume */
	inline public static var UNI_ITEFFECTN=48;
	
	/* slide / fineslide channel volume */
	inline public static var UNI_ITEFFECTP=49;
	
	/* slide / fineslide channel panning */
	inline public static var UNI_ITEFFECTT=50;
	
	/* slide tempo */
	inline public static var UNI_ITEFFECTU=51;
	
	/* fine vibrato */
	inline public static var UNI_ITEFFECTW=52;
	
	/* slide / fineslide global volume */
	inline public static var UNI_ITEFFECTY=53;
	
	/* panbrello */
	inline public static var UNI_ITEFFECTZ=54;
	
	/* resonant filters */
	inline public static var UNI_ITEFFECTS0=55;
	
	/* UltraTracker effects */
	inline public static var UNI_ULTEFFECT9=56;
	
	/* Sample fine offset */
	
	/* OctaMED effects */
	inline public static var UNI_MEDSPEED=57;
	inline public static var UNI_MEDEFFECTF1=58;
	
	/* play note twice */
	inline public static var UNI_MEDEFFECTF2=59;
	
	/* delay note */
	inline public static var UNI_MEDEFFECTF3=60;
	
	/* play note three times */
	
	/* Oktalyzer effects */
	inline public static var UNI_OKTARP=61;
	
	/* arpeggio */
	inline public static var UNI_LAST=62;
	
	/* Instrument format flags */
	inline public static var IF_OWNPAN=1;
	inline public static var IF_PITCHPAN=2;
	
	/* Envelope flags: */
	inline public static var EF_ON=1;
	inline public static var EF_SUSTAIN=2;
	inline public static var EF_LOOP=4;
	inline public static var EF_VOLENV=8;
	
	/* New Note Action Flags */
	inline public static var NNA_CUT=0;
	inline public static var NNA_CONTINUE=1;
	inline public static var NNA_OFF=2;
	inline public static var NNA_FADE=3;
	inline public static var NNA_MASK=3;
	inline public static var DCT_OFF=0;
	inline public static var DCT_NOTE=1;
	inline public static var DCT_SAMPLE=2;
	inline public static var DCT_INST=3;
	inline public static var DCA_CUT=0;
	inline public static var DCA_OFF=1;
	inline public static var DCA_FADE=2;
	inline public static var KEY_KICK=0;
	inline public static var KEY_OFF=1;
	inline public static var KEY_FADE=2;
	inline public static var KEY_KILL=(KEY_OFF|KEY_FADE);
	inline public static var KICK_ABSENT=0;
	inline public static var KICK_NOTE=1;
	inline public static var KICK_KEYOFF=2;
	inline public static var KICK_ENV=4;
	inline public static var AV_IT=1;
	
	/* IT vs. XM vibrato info */
	inline public static var OCTAVE=12;
	
	/* IT / S3M Extended SS effects: */
	// enum
	inline public static var SS_GLISSANDO = 1;
	inline public static var SS_FINETUNE=2;
	inline public static var SS_VIBWAVE=3;
	inline public static var SS_TREMWAVE=4;
	inline public static var SS_PANWAVE=5;
	inline public static var SS_FRAMEDELAY=6;
	inline public static var SS_S7EFFECTS=7;
	inline public static var SS_PANNING=8;
	inline public static var SS_SURROUND=9;
	inline public static var SS_HIOFFSET=10;
	inline public static var SS_PATLOOP=11;
	inline public static var SS_NOTECUT=12;
	inline public static var SS_NOTEDELAY=13;
	inline public static var SS_PATDELAY=14;
	
	/* flags for S3MIT_ProcessCmd */
	inline public static var S3MIT_OLDSTYLE=1;
	
	/* behave as old scream tracker */
	inline public static var S3MIT_IT=2;
	
	/* behave as impulse tracker */
	inline public static var S3MIT_SCREAM=4;
	
	/* enforce scream tracker specific limits */
	
	/*
 *      ========== Error codes
 */
	//enum {
	inline public static var MMERR_OPENING_FILE = 1;
	inline public static var MMERR_OUT_OF_MEMORY=2;
	inline public static var MMERR_DYNAMIC_LINKING=3;
	inline public static var MMERR_NOT_A_MODULE=4;
	inline public static var MMERR_LOADING_HEADER=5;
	inline public static var MMERR_OUT_OF_HANDLES=6;
	inline public static var MMERR_LOADING_PATTERN=7;
	inline public static var MMERR_LOADING_SAMPLEINFO=8;
	inline public static var MMERR_ITPACK_INVALID_DATA=9;
	
	/*
 *      ========== Drivers
 */
	inline public static var MD_MUSIC=0;
	inline public static var MD_SNDFX=1;
	inline public static var MD_HARDWARE=0;
	inline public static var MD_SOFTWARE=1;
	
	/* Mixing flags */
	
	/* These ones take effect only after MikMod_Init or MikMod_Reset */
	inline public static var DMODE_16BITS=0x0001;
	
	/* enable 16 bit output */
	inline public static var DMODE_STEREO=0x0002;
	
	/* enable stereo output */
	inline public static var DMODE_SOFT_SNDFX=0x0004;
	
	/* Process sound effects via software mixer */
	inline public static var DMODE_SOFT_MUSIC=0x0008;
	
	/* Process music via software mixer */
	inline public static var DMODE_HQMIXER=0x0010;
	
	/* Use high-quality (slower) software mixer */
	inline public static var DMODE_FLOAT=0x0020;
	
	/* enable float output */
	
	/* These take effect immediately. */
	inline public static var DMODE_SURROUND=0x0100;
	
	/* enable surround sound */
	inline public static var DMODE_INTERP=0x0200;
	
	/* enable interpolation */
	inline public static var DMODE_REVERSE=0x0400;
	
	/* reverse stereo */
	public static var npertab=[
		/* Octaves 6 -> 0 */
		/* C    C#     D    D#     E     F    F#     G    G#     A    A#     B */
		0x6b0,0x650,0x5f4,0x5a0,0x54c,0x500,0x4b8,0x474,0x434,0x3f8,0x3c0,0x38a,
		0x358,0x328,0x2fa,0x2d0,0x2a6,0x280,0x25c,0x23a,0x21a,0x1fc,0x1e0,0x1c5,
		0x1ac,0x194,0x17d,0x168,0x153,0x140,0x12e,0x11d,0x10d,0x0fe,0x0f0,0x0e2,
		0x0d6,0x0ca,0x0be,0x0b4,0x0aa,0x0a0,0x097,0x08f,0x087,0x07f,0x078,0x071,
		0x06b,0x065,0x05f,0x05a,0x055,0x050,0x04b,0x047,0x043,0x03f,0x03c,0x038,
		0x035,0x032,0x02f,0x02d,0x02a,0x028,0x025,0x023,0x021,0x01f,0x01e,0x01c,
		0x01b,0x019,0x018,0x016,0x015,0x014,0x013,0x012,0x011,0x010,0x00f,0x00e
	];
	
	/* Instrument note count */
	inline public static var INSTNOTES=120;
	inline public static var ENVPOINTS=32;
	
	/* IT resonant filter information */
	inline public static var UF_MAXMACRO=0x10;
	inline public static var UF_MAXFILTER=0x100;
	inline public static var FILT_CUT=0x80;
	inline public static var FILT_RESONANT=0x81;
	
	/* IT Volume column effects */
	inline public static var VOL_VOLUME = 1;
	inline public static var VOL_PANNING = 2;
	inline public static var VOL_VOLSLIDE = 3;
	inline public static var VOL_PITCHSLIDEDN = 4;
	inline public static var VOL_PITCHSLIDEUP = 5;
	inline public static var VOL_PORTAMENTO = 6;
	inline public static var VOL_VIBRATO = 7;
	
	/* Module definition */
	
	/* maximum master channels supported */
	inline public static var UF_MAXCHAN=64;
	
	/* Module flags */
	inline public static var UF_XMPERIODS=0x0001;
	
	/* XM periods / finetuning */
	inline public static var UF_LINEAR=0x0002;
	
	/* LINEAR periods (UF_XMPERIODS must be set) */
	inline public static var UF_INST=0x0004;
	
	/* Instruments are used */
	inline public static var UF_NNA=0x0008;
	
	/* IT: NNA used, set numvoices rather than numchn */
	inline public static var UF_S3MSLIDES=0x0010;
	
	/* uses old S3M volume slides */
	inline public static var UF_BGSLIDES=0x0020;
	
	/* continue volume slides in the background */
	inline public static var UF_HIGHBPM=0x0040;
	
	/* MED: can use >255 bpm */
	inline public static var UF_NOWRAP=0x0080;
	
	/* XM-type (i.e. illogical) pattern break semantics */
	inline public static var UF_ARPMEM=0x0100;
	
	/* IT: need arpeggio memory */
	inline public static var UF_FT2QUIRKS=0x0200;
	
	/* emulate some FT2 replay quirks */
	inline public static var UF_PANNING=0x0400;
	
	/* module uses panning effects or have non-tracker default initial panning */
}
