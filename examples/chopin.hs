
import Music.Prelude

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
main = defaultMain music
