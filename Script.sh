Context: STOI-14396. The scan-golden (OpenSCAP STIG) stage is red at 84.4% (184/218), 
under the 85% gate. You've shown the 580 bump is innocent (scan #2/535 and scan #3/580 are 
byte-identical, so the driver didn't cause it). I need to close ATTRIBUTION to zero doubt 
before I act on it, and separately find out if it blocks my release. coreservices-images-l 
is re-authed now. Read-only: NO builds, commits, or pushes.

Important nuance to respect: the #2-vs-#3 identity isolates the DRIVER only -- both builds 
have Fabric Manager enabled, so it does NOT by itself clear the FM addition. The pass->fail 
transition is between scan #1 (Oct 8, pre-FM, passed) and scan #2 (FM added + ~3 weeks of 
main drift). So FM-addition and main-drift are both candidates until the checks below 
separate them. Don't conclude "not ours" until BOTH are satisfied.

1. FAILING-RULE LIST: from the OpenSCAP compliance.json on S3 for scan #3 (the 580 build), 
   pull the full list of the ~34 failing rules. For each, give the rule ID/title and group 
   it: generic OS STIG (sshd / pam / auditd / file-perms / kernel / login) vs anything that 
   touches NVIDIA, drivers, kernel modules, enabled services, or installed packages. State 
   plainly: is ANY failing rule something the FM addition (a newly enabled service / added 
   packages) could have caused? If yes, list those specifically.

2. BASELINE COMPARISON: find the OpenSCAP score for a CURRENT non-NVIDIA image built from 
   main in the same window (e.g. a base/btp Ubuntu-22 golden scan). Report its score AND, if 
   you can get it, its failing-rule set. Then DIFF the failing sets: is the branch's set of 
   34 identical to / a subset of main's? Any rule the branch fails that main does NOT is a 
   branch-introduced failure -- flag those explicitly and cross-check them against the FM 
   additions from step 1.

3. GATE / RELEASE IMPACT: determine whether scan-golden is a REQUIRED gate for the MR/release 
   or advisory. I.e. at 84.4% (<85%), does this stage block STOI-14396's image from merging/ 
   shipping, or is it non-blocking? Check how the pipeline treats a sub-gate scan score.

Verdict: only state "pre-existing main-baseline regression, not introduced by STOI-14396" 
if (a) NO failing rule is NVIDIA/FM-related AND (b) current main shows the same failures. If 
either fails, say so and show which rules are on us. Also give the blocking/non-blocking 
answer separately. Evidence for every claim; change nothing.
