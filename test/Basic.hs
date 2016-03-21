
{-# LANGUAGE FlexibleContexts, OverloadedStrings #-}

import Music.Prelude
import Control.Lens(set)

-- music-suite/test/legacy-music-files/articulation_all_accents.music
articulation_all_accents :: Music
articulation_all_accents =
  accent (scat [c..g]|/8)
      </>
  marcato (scat [c..g]|/8)


-- music-suite/test/legacy-music-files/articulation_all_separations.music
articulation_all_separations :: Music
articulation_all_separations =
  legato (scat [c..g]|/8)
      </>
  staccato (scat [c..g]|/8)
      </>
  portato (scat [c..g]|/8)
      </>
  tenuto (scat [c..g]|/8)
      </>
  separated (scat [c..g]|/8)
      </>
  spiccato (scat [c..g]|/8)


-- music-suite/test/legacy-music-files/articulation_legato.music
articulation_legato :: Music
articulation_legato =
  legato (scat [c..g]|/8)


-- music-suite/test/legacy-music-files/articulation_portato.music
articulation_portato :: Music
articulation_portato =
  portato (scat [c..g]|/8)


-- music-suite/test/legacy-music-files/articulation_staccato.music
articulation_staccato :: Music
articulation_staccato =
  staccato (scat [c..g]|/8)

-- TODO articulation, more high-level combinators (a la photoshop)


-- music-suite/test/legacy-music-files/decl_style1.music
-- decl_style1 =
--
--   data Foo = Foo | Bar
--
--   scale Foo = scat [c,d,e,f,g,a,g,f]|/8
--   scale Bar = scale Foo
--
--   triad a = a <> up _M3 a <> up _P5 a
--
--   example = up _P8 (scale Foo) </> (triad c)|/2 |> (triad g_)|/2



-- music-suite/test/legacy-music-files/dynamics_constant.music
dynamics_test :: Music
dynamics_test =
  scat $ zipWith level [fff,ff,_f,mf,mp,_p,pp,ppp] [c..]

dynamics_test2 :: Music
dynamics_test2 =
  scat $ louder 1 $ zipWith level [pp,ff,pp] [c,d,e]

dynamics_test3 :: Music
dynamics_test3 =
  scat $ softer 1 $ zipWith level [pp,ff,pp] [c,d,e]

dynamics_test4 :: Music
dynamics_test4 =
  scat $ softer (ff-pp) $ zipWith level [pp,ff,pp] [c,d,e]

-- TODO more dynamics (fadeIn, fadeOut, alternate fade curves, compress up/down)

-- TODO ties
-- We probably need to retain this for internal purposes, but can we trim
-- the API?

-- TODO color
-- Should be moved to meta

-- music-suite/test/legacy-music-files/melody_chords.music
melody_chords :: Music
melody_chords =
  let
      scale = scat [c,d,e,f,g,a,g,f] |/ 8
      triad a = a <> up _M3 a <> up _P5 a
  in up _P8 scale </> (triad c)|/2 |> (triad g_)|/2


-- music-suite/test/legacy-music-files/meta_annotations.music
meta_annotations :: Music
meta_annotations =
  showAnnotations $ annotate "First note" c |> d |> annotate "Last note" d

meta_annotations2 :: Music
meta_annotations2 =
  showAnnotations $ annotate "First note" $ scat [c,d,e]

meta_annotations3 :: Music
meta_annotations3 =
  showAnnotations $ annotateSpan (1 <-> 2) "First note" $ scat [c,d,e]

meta_barlines :: Music
meta_barlines = scat [c{-, barline-}, d{-, doubleBarline-}, e, f {-, finalBarline-}]

-- music-suite/test/legacy-music-files/meta_composer.music
meta_attribution :: Music
meta_attribution =
  composer "Anonymous" $ scat [c,d,e,c]

meta_attribution2 :: Music
meta_attribution2 =
  lyricist "Anonymous" $ scat [c,d,e,c]

meta_attribution3 :: Music
meta_attribution3 =
  arrangerDuring (0 <-> 1) "Anonymous I" $
  arrangerDuring (1 <-> 2) "Anonymous II" $
    scat [c,d,e,c]


-- music-suite/test/legacy-music-files/meta_clef1.music
meta_clef1 :: Music
meta_clef1 =
  let
      part1 = clef f $ staccato $ scat [c_,g_,c,g_]
      part2 = clef c $ staccato $ scat [ab_,eb,d,a]
      part3 = clef g $ staccato $ accentLast $ scat [g,fs,e,d]
  in compress 8 $ part1 |> part2 |> part3
  -- TODO need a better API here, integrated with Music.Pitch.Clef
  -- This should only be a hint, as clefs should be automatically inferred

-- meta_fermata :: Music
-- meta_fermata = scat [c, d, fermata StandardFermata e]
-- TODO does not work (Fermata /~ FermataType)
-- TODO just saying "fermata" should yield a standard fermata

-- meta_fermata2 :: Music
-- meta_fermata2 = scat [c, d, fermata LongFermata e]

-- meta_fermata3 :: Music
-- meta_fermata3 = fermataAt 2 $ scat [c, d, e]
-- TODO does not work (Fermata /~ FermataType)
-- TODO remove fermataDuring, add fermataAt (fermatas attach to points, not spans)


meta_key_signature :: Music
meta_key_signature =
  keySignature (key 1 False) $ scat [c,d,e,f,g]
  -- TODO should really be (keySignature g major) or similar
  -- Integrate with music-pitch

-- meta_rehearsal_mark :: Music
-- meta_rehearsal_mark =
  -- rehearsalMark $ scat [c,d,e,f,g]
  -- TODO

-- music-suite/test/legacy-music-files/meta_time_signature.music
meta_time_signature :: Music
meta_time_signature =
  compress 4 $ timeSignature (4/4) (scat [c,d,e,c,d,e,f,d,g,d]) |> timeSignature (3/4) (scat [a,g,f,g,f,e])

-- music-suite/test/legacy-music-files/meta_time_signature.music
meta_time_signature2 :: Music
meta_time_signature2 =
  compress 16 $ timeSignature ((3+2)/16) $ scat [c,d,e,f,g]

meta_tempo :: Music
meta_tempo = scat
  [ tempo presto $ scat [c,d,e,f,g]
  , tempo allegretto $ scat [c,d,e,f,g]
  , tempo (metronome (1/4) 48) $ scat [c,d,e,f,g]
  ]
  -- TODO custom tempo names

-- music-suite/test/legacy-music-files/meta_title.music
meta_title :: Music
meta_title =
  title "Piece" $ scat [c,d,e,c]

meta_title2 :: Music
meta_title2 =
  subtitle "I" $ scat [c,d,e,c]
  -- TODO alternative for indexing movements by number etc

-- music-suite/test/legacy-music-files/misc_counterpoint.music
misc_counterpoint :: Music
misc_counterpoint =
  let
      subj = scat $ scat [ [c],       [d],        [f],          [e]           ]
      cs1  = scat $ scat [ [g,f,e,g], [f,a,g,d'], [c',b,c',d'], [e',g',f',e'] ]
  in compress 4 cs1 </> subj


-- music-suite/test/legacy-music-files/octaves.music
octaves :: Music
octaves =
  c__ |> c_ |> c |> c' |> c''


-- music-suite/test/legacy-music-files/overlay_chords.music
overlay_chords :: Music
overlay_chords =

  pcat [c,e,g] |> pcat [d,f,a] |> pcat [e,g,b] |> pcat [c,e,g]


-- music-suite/test/legacy-music-files/overlay_voices.music
overlay_voices :: Music
overlay_voices =
  scat [c,d,e,c] <> scat [e,f,g,e] <> scat [g,a,b,g]

voice1 :: Voice Pitch
voice1 = a -- mconcat [a,a,b,b,b,b,c,c]
  where
    a = [(1,c)^.note, (1,d)^.note, (2,e)^.note]^.voice
    -- b = [(1,d)^.note]^.voice
    -- c = [(2,c)^.note]^.voice

-- music-suite/test/legacy-music-files/pitch_inv.music
pitch_inv :: Music
pitch_inv =
  (scat [c..g]|*(2/5))
      </>
  (invertPitches c $ scat [c..g]|*(2/5))
      </>
  (invertPitches e $ scat [c..g]|*(2/5))


-- music-suite/test/legacy-music-files/sharpen.music
sharpen' :: Music
sharpen' =
  sharpen c
      </>
  (sharpen . sharpen) c


-- music-suite/test/legacy-music-files/simple_figure.music
simple_figure :: Music
simple_figure =
  (c |> d |> e |> c |> d|*2 |> d|*2)|/16


-- music-suite/test/legacy-music-files/simple_start_later.music
simple_start_later :: Music
simple_start_later =
  up _P8 . compress 2 . delay 3 $ c


-- music-suite/test/legacy-music-files/single_note.music
single_note :: Music
single_note =
  c


-- music-suite/test/legacy-music-files/special_gliss.music
special_gliss :: Music
special_gliss =
  glissando $ scat [c,d]|/2
-- TODO slide/gliss
-- This should be moved to pitch using Behavior or similar
-- How?

-- music-suite/test/legacy-music-files/special_harmonics.music
special_harmonics :: Music
special_harmonics =
  (harmonic 1 $ c|/2)
      </>
  (harmonic 2 $ c|/2)
      </>
  (harmonic 3 $ c|/2)
-- TODO should be moved to techniques
-- Nicer way of distinguishing artificial/natural (for instruments where this
-- makes sense).

-- music-suite/test/legacy-music-files/special_text.music
special_text :: Music
special_text =
  text "pizz." $ c|/2
-- TODO text
-- Should be split up into expressive marks (lento, dolce etc) and what else
-- Lyrics should be separate
-- Arguably all technical instructions (pizz etc) are better represented as
-- part of the instrument/technique tuple.



-- music-suite/test/legacy-music-files/special_tremolo.music
special_tremolo :: Music
special_tremolo =
  tremolo 2 $ times 2 $ (c |> d)|/2
-- TODO should be moved to techniques
-- Would not mind retaining this top-level combinator
-- What about unmeasured tremolo?


-- music-suite/test/legacy-music-files/stretch_single_note1.music
stretch_single_note1 :: Music
stretch_single_note1 =
  stretch (1/2) c


-- music-suite/test/legacy-music-files/stretch_single_note2.music
stretch_single_note2 :: Music
stretch_single_note2 =
  stretch (1/2) c


-- music-suite/test/legacy-music-files/stretch_single_note3.music
stretch_single_note3 :: Music
stretch_single_note3 =
  stretch (4+1/2) c


-- music-suite/test/legacy-music-files/times.music
times' :: Music
times' =
  let
      melody = legato $ scat [c,d,e,cs,ds,es]|/16
  in times 4 $ melody


-- music-suite/test/legacy-music-files/track_single.music
track_single :: Music
track_single =
  let
      x = [ (0, c)^.placed, (1, d)^.placed, (2, e)^.placed ]^.track
      y = join $ [ (0, x)^.placed,
                  (1.5,  up _P5 x)^.placed,
                  (3.25, up _P8 x)^.placed ]^.track

      trackToScore d = view score . map (view event . (\(t,x) -> (t >-> d,x)) . (view $ from placed)) . view placeds

  in trackToScore (1/8) y
-- TODO can we do without/rename track
-- TODO note vs event
--   Irritating that we can not call the things are score is made up of "notes"
--   Maybe use a parameterized type (data family?) such as (Note Voice :: * -> *)
-- (Note Score :: * -> *), i.e. Note has kind ((* -> *) -> * -> *) etc.

string_quartet :: Music
string_quartet = mainCanon2
  where
    mainCanon2 = (palindrome mainCanon <> celloEntry) |> tremCanon

    celloEntry = set parts' cellos e''|*(25*5/8)

    mainCanon = timeSignature (time 6 8) $ asScore $
        (set parts' violins1 $ harmonic 2 $ times 50 $ legato $ accentLast $
            octavesUp 2 $ scat [a_,e,a,cs',cs',a,e,a_]|/8)
            <>
        (set parts' violins2 $ harmonic 2 $ times 50 $ legato $ accentLast $
            octavesUp 2 $ scat [d,g,b,b,g,d]|/8)|*(3/2)
            <>
        (set parts' violas $ harmonic 2 $ times 50 $ legato $ accentLast $
            octavesUp 2 $ scat [a,d,a,a,d,a]|/8)|*(3*2/2)
            <>
        set parts' cellos a'|*(25*5/8)

    tremCanon = compress 4 $
        (delay 124 $ set parts' violins1 $ subjs|*1)
            <>
        (delay 120 $ set parts' violins2 $ subjs|*1)
            <>
        (delay 4 $ set parts' violas $ subjs|*2)
            <>
        (delay 0 $ set parts' cellos  $ subjs|*2)
        where
          subjs = scat $ map (\n -> palindrome $ rev $ subj n) [1..40::Int]
          subj n
              | n < 8     = a_|*2  |> e|*1   |> a|*1
              | n < 16    = a_|*2  |> e|*1   |> a|*1   |> e|*1   |> a|*1
              | n < 24    = a_|*2  |> e|*0.5 |> a|*0.5 |> e|*0.5 |> a|*0.5
              | otherwise = e|*0.5 |> a|*0.5

bartok_mikrokosmos :: Music
bartok_mikrokosmos = let
    meta = id
      . title "Mikrokosmos (excerpt)"
      . composer "Bela Bartok"
      . timeSignature (2/4)
      . timeSignatureDuring ((2/4) >-> (5/4)) (3/4)

    left = (level pp . legato)
         (scat [a,g,f,e] |> d|*2)
      |> {-(level ((mp |> mp `cresc` mf |> mf)|*8) . legato)-}id
         (scat [g,f,e,d] |> c |> (d |> e)|/2 |> f |> e |> d|*8)
    --
    right = up _P4 . delay 2 $
         (level pp . legato)
         (scat [a,g,f,e] |> d|*2)
      |> (level mp . legato)
         (scat [g,f,e,d] |> c |> (d |> e)|/2 |> f |> e |> d|*8)

  in meta $ compress 8 $ left <> set parts' cellos (down _P8 right)

chopin_etude :: Music
chopin_etude = music
  where
    rh :: Music
    rh = [((1/2) <-> (3/4),e)^.event,((3/4) <-> (15/16),cs')^.event,((15/16) <-> 1,d')^.event,(1 <-> (5/4),d)^.event,(1 <->
      (5/4),gs)^.event,(1 <-> (5/4),b)^.event,((5/4) <-> (3/2),d)^.event,((5/4) <-> (3/2),gs)^.event,((5/4) <->
      (3/2),b)^.event,((3/2) <-> 2,d)^.event,((3/2) <-> 2,gs)^.event,((3/2) <-> 2,b)^.event,(2 <-> (9/4),d')^.event,(2 <->
      (9/4),fs')^.event,((9/4) <-> (39/16),bs)^.event,((9/4) <-> (39/16),ds')^.event,((39/16) <-> (5/2),cs')^.event,((39/16) <->
      (5/2),e')^.event,((5/2) <-> (11/4),cs')^.event,((5/2) <-> (11/4),a')^.event,((11/4) <-> 3,cs')^.event,((11/4) <->
      3,a')^.event,(3 <-> (7/2),cs')^.event,(3 <-> (7/2),a')^.event,((7/2) <-> (15/4),e)^.event,((7/2) <->
      (15/4),cs')^.event,((15/4) <-> (63/16),cs)^.event,((15/4) <-> (63/16),as)^.event,((63/16) <-> 4,d)^.event,((63/16) <->
      4,b)^.event,(4 <-> (17/4),fs)^.event,(4 <-> (17/4),d')^.event,((17/4) <-> (9/2),fs)^.event,((17/4) <->
      (9/2),d')^.event,((9/2) <-> 5,fs)^.event,((9/2) <-> 5,d')^.event,(5 <-> (21/4),d)^.event,(5 <-> (21/4),gs)^.event,((21/4)
      <-> (87/16),d)^.event,((21/4) <-> (87/16),gs)^.event,((87/16) <-> (11/2),cs)^.event,((87/16) <-> (11/2),a)^.event,((11/2)
      <-> (23/4),cs)^.event,((11/2) <-> (23/4),cs')^.event,((23/4) <-> 6,cs)^.event,((23/4) <-> 6,cs')^.event,(6 <->
      (13/2),cs)^.event,(6 <-> (13/2),cs')^.event]^.score

    lh :: Music
    lh = [((3/4) <-> 1,e__)^.event,(1 <-> (5/4),e_)^.event,(1 <-> (5/4),e)^.event,((5/4) <-> (3/2),e_)^.event,((5/4) <->
      (3/2),e)^.event,((3/2) <-> 2,e_)^.event,((3/2) <-> 2,e)^.event,((9/4) <-> (5/2),a__)^.event,((5/2) <->
      (11/4),a_)^.event,((5/2) <-> (11/4),e)^.event,((11/4) <-> 3,a_)^.event,((11/4) <-> 3,e)^.event,(3 <-> (7/2),a_)^.event,(3
      <-> (7/2),e)^.event,((15/4) <-> 4,e__)^.event,(4 <-> (17/4),e_)^.event,(4 <-> (17/4),b_)^.event,((17/4) <->
      (9/2),e_)^.event,((17/4) <-> (9/2),b_)^.event,((9/2) <-> 5,e_)^.event,((9/2) <-> 5,b_)^.event,((21/4) <->
      (11/2),a___)^.event,((11/2) <-> (23/4),e_)^.event,((11/2) <-> (23/4),a_)^.event,((11/2) <-> (23/4),e)^.event,((23/4) <->
      6,e_)^.event,((23/4) <-> 6,a_)^.event,((23/4) <-> 6,e)^.event,(6 <-> (13/2),e_)^.event,(6 <-> (13/2),a_)^.event,(6 <->
      (13/2),e)^.event]^.score

    music = timeSignature (3/4) $ lh <> rh

-- music-suite/test/legacy-music-files/voice_single.music
-- voice_single =
--   let
--       x = [ (1, c)^.note,
--             (1, d)^.note,
--             (1, f)^.note,
--             (1, e)^.note ]^.voice
--
--       y = join $ [ (1, x)^.note,
--                    (0.5, up _P5 x)^.note,
--                    (4, up _P8 x)^.note ]^.voice
--
--   in stretch (1/8) $ view (re singleMVoice) . fmap Just $ y


main = return ()
