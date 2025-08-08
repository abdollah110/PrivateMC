#!/bin/bash
if [ "$STARTED_SINGULARITY" = "" ]; then
  export STARTED_SINGULARITY=1
  top_dir=$(pwd -P | sed 's|\(/[^/]*\).*|\1|')
  MOUNTS=" -B $top_dir"
  scratch_dir=$(echo $_CONDOR_SCRATCH_DIR | sed 's|\(/[^/]*\).*|\1|')
  if [ "$scratch_dir" != "" ] && [ "$scratch_dir" != "$top_dir" ]; then
      MOUNTS=" -B $scratch_dir $MOUNTS"
  fi
  this_script=./$(basename $0)
  export SINGULARITY_CACHEDIR="$(pwd)/singularity"
  exec singularity exec --no-home $MOUNTS -B /cvmfs -B /etc/grid-security/certificates /cvmfs/singularity.opensciencegrid.org/cmssw/cms:rhel7 $this_script "$@"
  echo "Failed to execute singularity: $?"
  exit 1
fi




#!/bin/bash
export HOME=$(pwd)
nthd=2
EVENTS=$2
seed=$1
name="_8b"
export SCRAM_ARCH=slc7_amd64_gcc820
exit_on_error() {
    result=$1
    code=$2
    message=$3

    if [ $1 != 0 ]; then
        echo $3
        exit $2
    fi
} 


source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_47_patch1/src ] ; then
  echo release CMSSW_10_6_47_patch1 already exists
else
  scram p CMSSW CMSSW_10_6_47_patch1
fi
cd CMSSW_10_6_47_patch1/src
eval $(scram runtime -sh)

pwd

ls -ltr



mkdir -p Configuration/GenProduction/python
cp ../../fragment${name}.py  Configuration/GenProduction/python/.
cp ../../ExoHiggsTo8b_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz  Configuration/GenProduction/python/.

scram  b -j 8



cmsDriver.py Configuration/GenProduction/python/fragment${name}.py --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${seed})" --python_filename ExoHiggs${name}_UL18wmLHEGEN_1_cfg.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:ExoHiggs${name}_UL18wmLHEGEN.root --conditions 106X_upgrade2018_realistic_v4 --beamspot Realistic25ns13TeVEarly2018Collision --step LHE,GEN --geometry DB:Extended --era Run2_2018 --no_exec --mc -n $EVENTS || exit $? ;

cmsRun ExoHiggs${name}_UL18wmLHEGEN_1_cfg.py





cmsDriver.py  --python_filename ExoHiggs${name}_UL18SIM_1_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:ExoHiggs${name}_UL18SIM.root --conditions 106X_upgrade2018_realistic_v11_L1v1 --beamspot Realistic25ns13TeVEarly2018Collision --step SIM --geometry DB:Extended --filein file:ExoHiggs${name}_UL18wmLHEGEN.root --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

cmsRun ExoHiggs${name}_UL18SIM_1_cfg.py


voms-proxy-info




cmsDriver.py  --python_filename ExoHiggs${name}_UL18DIGIPremix_1_cfg.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --fileout file:ExoHiggs${name}_UL18DIGIPremix.root --pileup_input "root://cmsxrootd.hep.wisc.edu//store/user/abdollah/8546F9BD-3C6B-A842-BAE6-4BBD14F90F67.root" --conditions 106X_upgrade2018_realistic_v11_L1v1 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --filein file:ExoHiggs${name}_UL18SIM.root --datamix PreMix --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

cmsRun ExoHiggs${name}_UL18DIGIPremix_1_cfg.py


cd ../../


if [ -r CMSSW_10_2_16_UL/src ] ; then
  echo release CMSSW_10_2_16_UL already exists
else
  scram p CMSSW CMSSW_10_2_16_UL
fi
cd CMSSW_10_2_16_UL/src
eval $(scram runtime -sh)
scram  b -j 8



cmsDriver.py  --python_filename ExoHiggs${name}_UL18HLT_1_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:ExoHiggs${name}_UL18HLT.root --conditions 102X_upgrade2018_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2018v32 --geometry DB:Extended --filein file:../../CMSSW_10_6_47_patch1/src/ExoHiggs${name}_UL18DIGIPremix.root --era Run2_2018 --no_exec --mc -n $EVENTS || exit $? ;


cmsRun ExoHiggs${name}_UL18HLT_1_cfg.py


cd ../../
cd CMSSW_10_6_47_patch1/src
cmsenv
scram b -j 8



cmsDriver.py  --python_filename ExoHiggs${name}_UL18RECO_1_cfg.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:ExoHiggs${name}_UL18RECO.root --conditions 106X_upgrade2018_realistic_v11_L1v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --geometry DB:Extended --filein file:../../CMSSW_10_2_16_UL/src/ExoHiggs${name}_UL18HLT.root --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

cmsRun ExoHiggs${name}_UL18RECO_1_cfg.py




cmsDriver.py  --python_filename ExoHiggs${name}_UL18MiniAOD_1_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:ExoHiggs${name}_UL18MiniAOD.root --conditions 106X_upgrade2018_realistic_v11_L1v1 --step PAT --geometry DB:Extended --filein file:ExoHiggs${name}_UL18RECO.root --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

cmsRun ExoHiggs${name}_UL18MiniAOD_1_cfg.py



cmsDriver.py  --python_filename ExoHiggs${name}_UL18NanoAODv2_1_cfg.py --eventcontent NANOAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier NANOAODSIM --fileout file:ExoHiggs${name}_UL18NanoAODv2.root --conditions 106X_upgrade2018_realistic_v15_L1v1 --step NANO --filein file:ExoHiggs${name}_UL18MiniAOD.root --era Run2_2018,run2_nanoAOD_106Xv1 --no_exec --mc -n $EVENTS || exit $? ;

cmsRun  ExoHiggs${name}_UL18NanoAODv2_1_cfg.py






echo "Final Gen events: $nevt0"
echo "Final SIM events: $nevt1"
echo "Final DIGI events: $nevt2"
echo "Final HLT events: $nevt3"
echo "Final RECO events: $nevt4"
echo "Final miniAOD events: $nevt5"

eval `scram unsetenv -sh`

gfal-copy -p ExoHiggs${name}_UL18MiniAOD.root   davs://cmsxrootd.hep.wisc.edu:1094/store/user/abdollah/${seed}_ExoHiggs${name}_UL18MiniAOD.root

gfal-copy -p ExoHiggs${name}_UL18NanoAODv2.root   davs://cmsxrootd.hep.wisc.edu:1094/store/user/abdollah/${seed}_ExoHiggs${name}_UL18NanoAODv2.root


