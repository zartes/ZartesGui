function ALL=GetAllPparam(P)
%%%funcion que devuelve en arrayus todos los parámetros de P. Daría lo
%%%mismo hacer [P(i).p.{par}] pero esto puede simplificar la creacion de
%%%combinaciones de parametros mas complejas.

ALL.rp=[P.p.rp];
ALL.R0=[P.p.R0];
ALL.L0=[P.p.L0];
ALL.ai=[P.p.ai];
ALL.bi=[P.p.bi];
ALL.tau0=[P.p.tau0];
ALL.taueff=[P.p.taueff];
ALL.C=[P.p.C];
ALL.Zinf=[P.p.Zinf];
ALL.Z0=[P.p.Z0];
ALL.ExRes=[P.p.ExRes];
ALL.ThRes=[P.p.ThRes];
ALL.M=[P.p.M];
ALL.Mph=[P.p.Mph];
ALL.Tb=P.Tbath;