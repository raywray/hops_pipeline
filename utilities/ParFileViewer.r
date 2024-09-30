#...........................................................................................
#---  Make transparent color -----------------------------------------------------
t_col <- function(color, percent = 50, name = NULL) {
  #      color = color name
  #    percent = % transparency
  #       name = an optional name for the color
  
  ## Get RGB values for named color
  rgb.val <- col2rgb(color)
  
  ## Make new color using input color as base and alpha set by transparency
  t.col <- rgb(rgb.val[1], rgb.val[2], rgb.val[3],
               max = 255,
               alpha = (100 - percent) * 255 / 100,
               names = name)
  
  ## Save the color
  invisible(t.col)
}
#................................................................................


#Change this directory to where your latest
# my.library.loc="C:/Users/excoffie/Documents/R/win-library/3.3"


library("plotrix", verbose=F)
library("diagram", verbose=F)

args=commandArgs(TRUE)

mutRateRescaling=1                          #Don't touch this!
genTime=1                                   #Don't touch this!
rescalingFactor=mutRateRescaling*genTime    #Don't touch this!
separator=" "                               #Don't touch this!


#--- Drawing variables -------- can be customized by user ------------------------------------------

#--- Colors
migrMatCol="dark grey"                          #Color of gene flow arrows
admixCol="blue"                             #Color of admixure events (single pulses of gene flow)
popFusionColor="black"                      #Color of population divergence lines
popCol="light grey"                             #Color of population size rectangles
popBorderCol="black"                        #Color of border of population size rectangles
timeCol="black"                              #Color of text for population size change
ageCol="light grey"                               #Color of text for population age
textInstbotColor="red"                      #Color of text size of instantaneous bottlenecks
instbotColor=t_col(textInstbotColor)        #Color of dos indicating size of instantaneous bottlenecks
pop_col_ar<-c(
            "#009E73", # green
            "#E69F00", # light orange
            "#CC79A7", # pink
            "#56B4E9", # light blue
            "#0072B2", # darker blue
            "#D55E00", # dark orange
            "#999999", # dark grey
            "#F0E442", # yellow
            "#332288", # midnight blue
            "#E0E0E0" # light grey
)

#--- Other parameters relative to plots
propLastsegment=0.05                        #Ppercentage of page to keep on y axis above last event 
migMatNameProp=0.8                          #Proportional size of text for migration matrices numbers
migMatLineLength=0.3                        #Size of separation line between times of use fo different migration matrices
timeProp=0.6                                #Proportional size of text for times of population size change
maxRadius=1/40                              #Max size for pop size circle in legend
minRadius=maxRadius/3                       #Min size for pop size circle in legend
arrowLength=0.2                             #Length of curved arrows indicative of gene flow
timeOffset=0.25                             #X axis separation between consecutive times shown in legend
migrOffset=0.05                             #X axis separation between consecutive migration matrices numbers  shown in legend
curvedArrowLTY=2                            #Type of line for curved gene flow arrows 
drawLogPopSize=T                            #Draw width of population sizes on a log scale or not
plotMigrRates=T                             #Show values of migration rates next to curved arrows
plotNmValues=F                              #Show Nm or m values (note that Nm values for growing pops 
                                            # are only shown for most recent pop sizes and may thus be irrelevant)
migrRateTextSizeCEX=0.4                     #Relative size of migration rate text
instBotAbsSize=F                            #Show absolute (T == 2N for 1 generation) or relative (F == t/2N) size of instantaneous bottlenecks
maxNumSpecialEvents=50                      #Number of each special events that can be stored and plotted (e.g. pop size changes, migration matrices, etc... )

#Define plot area size for PDF (in inches?!)
pdf.x.size=10
pdf.y.size=8

#------------------- end of customizable section ---------------------------------------------------

externalCall=F

if (!is.na(args[1]) & length(args)) { #Fix some parameters when script called from outside
  parFileName=args[1]   #Script shoudl be called with par file as a first parameter
  printPDF=T            #Printing pdf file by default
  usePopLabels=F        #Use popLabels on x axis, if "F" then plots deme numbers 0 1 2 3 etc...
  genTime=1             #Arbitrary generation time (if genTime !=1 then time is given in years)
  fixMaxTime=F          #Allow to plot only a given time scale up to maxTimeToPlot
  externalCall=T        #Just to say the program has been called from outside
} else { 
  
   #--- Set your own file and parameters
  
   printPDF=F
   
   #Specify the working directory here
   setwd("D:/Users/Laurent/Dropbox/fastsimcoal/ParFileViewer")
   
   parFileName= "3PopExpBot20Mb-v2.par"
   popLabels=c("Pop1", "Ghost", "Pop2","Pop3")
   usePopLabels=T         #Use popLabels on x axis, if "F" then plots deme numbers 0 1 2 3 etc...
   genTime=1              #Arbitrary generation time (if genTime !=1 then time is given in years)
   fixMaxTime=T           #Allow one to plot only a given time scale up to maxTimeToPlot
   maxTimeToPlot=8000     #Upper limit for time scale if fixMaxTime==T
   
}

if (!exists("popLabels")) usePopLabels=F else {
  if (is.na(popLabels[1]))  usePopLabels=F
}


###########################      Reading par file      #########################

parFile=scan(parFileName, character(0), sep = "\n", strip.white = TRUE, quiet=T) # separate each line

if (fixMaxTime) suffixZoom=paste("_zoom_", maxTimeToPlot, sep="") else suffixZoom=""

if (genTime==1) {
   suffixGen="_gens"
} else {
   suffixGen="_years"
}
if (externalCall) suffixGen="" 

pdfFileName=paste(parFileName, suffixZoom, suffixGen, ".pdf", sep="")

#--- Clean input file by removing consecutive separators, and keep ---------------

#--- Function to remove separators within a string
removeTrailingSep=function(string, sep) {
  temp=strsplit(string, split=sep)
  temp2=temp[[1]][nchar(temp[[1]])>0]
  cleanStr=temp2[1]
  if (length(temp2)>1) {
    for (i in 2:length(temp2)) {
      cleanStr=paste(cleanStr, temp2[i], sep=sep)
    }
  }
  cleanStr
}

#--- Replace Keep by -9999
replaceKeep=function(string) {
  if (grepl("keep", string)) {
    return(gsub("keep", "-9999", string))
  }
  return(string)
}

#Remove both multiple consecutive whitespace and tabs and replace keep keyword
for (i in 1:length(parFile)) {
  parFile[i]=removeTrailingSep(parFile[i], sep='\t')
  parFile[i]=removeTrailingSep(parFile[i], sep=' ')
  parFile[i]=replaceKeep(parFile[i])
}

#-------------------------------------------------------------------------------

#--- Get number of samples on line 2 -----
l.numsamples=parFile[2]
sp.l=unlist(strsplit(l.numsamples, split=' '))
tab.l=unlist(strsplit(l.numsamples, split='\t'))
if (length(sp.l)>=length(tab.l)) {
  numSamples=as.numeric(sp.l[1])
  separator=" "
} else {
  numSamples=as.numeric(tab.l[1])
  separator="\t"
}

numDemes=numSamples



#--- Reading numbers on separate lines -----
getNumbers=function(start, parFile, numSamples) {  
  for (i in 1:numSamples) {
    curnum=as.numeric(unlist(strsplit(parFile[start+i], split=separator))[1])
    if (i==1) {
      num=curnum 
    } else {
      num=c(num, curnum)
    }
  }
  num
}

#--- Get population sizes -----------------

#Initializing array to record pop size changes
numPopSizes=(1:numDemes)*0+1
popSizes=array(0, dim=c(maxNumSpecialEvents,numDemes))
popSizeTimeChange=array(0, dim=c(maxNumSpecialEvents,numDemes))
isGrowing=vector(mode="logical", length=numDemes)
curGrowthRates=(1:numDemes)*0
lastGrowthStartTime=(1:numDemes)*0-1

numGrowths=(1:numDemes)*0
startGrowthTimes=array(0, dim=c(maxNumSpecialEvents,numDemes))
endGrowthTimes=array(0, dim=c(maxNumSpecialEvents,numDemes))
startGrowthSize=array(0, dim=c(maxNumSpecialEvents,numDemes))
endGrowthSize=array(0, dim=c(maxNumSpecialEvents,numDemes))


start=3
popSizes[1,]=getNumbers(start, parFile, numSamples)
#Rescaling pop sizes
popSizes[1,]=round(popSizes[1,]*rescalingFactor, digits=0)

iniPopSizes=popSizes[1,]

#--- Get sample sizes -----------------

readSampleSizesTimesAndInbreedingLevel=function(start, parFile, numSamples) {
  for (i in 1:numSamples) {
    curLine=unlist(strsplit(parFile[start+i], split=separator))
    curSampSize=as.numeric(curLine[1])
    curSampTime=0
    curInbreeding=0
    if (length(curLine)>1) curSampTime=as.numeric(curLine[2])
    if (length(curLine)>2) curInbreeding=as.numeric(curLine[3])
    if (i==1) {
      sampSize=curSampSize
      sampTime=curSampTime
      inbreeding=curInbreeding
    } else {
      sampSize=c(sampSize,curSampSize)
      sampTime=c(sampTime,curSampTime)
      inbreeding=c(inbreeding,curInbreeding)
    }
  }
  list(ss=sampSize, st=sampTime, inb=inbreeding)
}

start=start+numSamples+1
# sampSizes=getNumbers(start, parFile, numSamples)
sampSizesStats=readSampleSizesTimesAndInbreedingLevel(start, parFile, numSamples)
#Rescaling for fsc
# sampTimes.rescaled=round(sampSizesStats$st*fsc.rescaling.factor, digits=0)
#Rescaling sample times
sampSizesStats$st=round(sampSizesStats$st*genTime, digits=0)

sampSizes=sampSizesStats$ss
sampTimes=sampSizesStats$st
inbrCoeff=sampSizesStats$inb

popSizeTimeChange[1,]=sampTimes

#--- Get growth rates -----------------
start=start+numSamples+1
growthRatesInitial=getNumbers(start, parFile, numSamples)
# save this into growthRates which will be used and updated when printing historical events
growthRates=growthRatesInitial
curGrowthRates=growthRatesInitial
for (i in 1:numDemes) {
  if (curGrowthRates[i]!=0) {
    isGrowing[i]=T
    lastGrowthStartTime=0
    numGrowths[i]=numGrowths[i]+1
    startGrowthTimes[numGrowths[i],i]=sampTimes[i]
    startGrowthSize[numGrowths[i],i]=iniPopSizes[i]
    
    #Loro_04_04_21 removed this as we draw growing pop using a different 
    # numPopSizes[i]=numPopSizes[i]+1
    # popSizes[numPopSizes[i], i]=iniPopSizes[i]
    # popSizeTimeChange[numPopSizes[i],i]=sampTimes[i]
    
  }
}

#--- Get number of migration matrices -----------------
start=start+numSamples+1
numMigMat=as.numeric(unlist(strsplit(parFile[start+1], split=separator))[1])

#--- Read migration matrix
readMigMat=function(start, parFile, numSamples) {
  for (i in 1:numSamples) {
    curmigs=as.numeric(unlist(strsplit(parFile[start+i], split=separator)))
    if (i==1) {
      migs=curmigs 
    } else {
      migs=rbind(migs, curmigs)
    }
  }
  rownames(migs)=1:numSamples
  migs 
}

#--- Get migration matrices as a list --------------
start=start+2
migMats=list()
if (numMigMat>0) {
  for (i in 1:numMigMat) {  
    curMigMat=readMigMat(start, parFile, numSamples) 
    migMats[[i]]=curMigMat
    start=start+numSamples+1
  }
}


#--- Get number of historical events
start=start+1
numHistEvents=as.numeric(unlist(strsplit(parFile[start], split=separator))[1])

timesPos=0
migrMatPos=numSamples+1

###################### HISTORICAL EVENTS HANDLING ##############################

#..... Read Historical Event .......

last.he.time=0
if (numHistEvents>0) {
  for (i in 1:numHistEvents) {
    start=start+1
    
    curHE=(1:9)*0
    
    curHE[1:7]=as.numeric(unlist(strsplit(parFile[start], split=separator))[1:7])
    
    #Take care of nomig keyword
    nomig=F
    if (grepl("nomig", parFile[start], ignore.case = T)) nomig=T
    
    #Take care of instbot keyword
    instbot=F
    if (grepl("instbot", parFile[start], ignore.case = T)) instbot=T
    
    
    #Take care of absoluteResize keyword
    absResize=F
    if (grepl("absoluteresize", parFile[start], ignore.case = T)) absResize=T
    
    if (nomig) curHE[7]=-1 
    if (instbot) curHE[8]=1 else curHE[8]=0
    if (absResize) curHE[9]=1 else curHE[9]=0
    
    #Rescaling time of event
    if (i==1) {
      curHE[1]=round(curHE[1]*genTime, digits=0)
      histEvents=curHE
      last.he.time=curHE[1]
    } else {
      curHE[1]=round(curHE[1]*genTime, digits=0)
      histEvents=rbind(histEvents, curHE)
      if (histEvents[i,1] > last.he.time) last.he.time=histEvents[i,1] 
    }
    
    curTime=curHE[1]
    source=curHE[2]+1
    sink=curHE[3]+1 
    sent=curHE[4]
    resize=curHE[5]
    growth=curHE[6]
    migmat=curHE[7]
  }
  if (numHistEvents>1) {
    rownames(histEvents)=1:numHistEvents
    colnames(histEvents)=c("time", "source", "sink", "migr", "resize", "growth", "migmat", "instBot", "absResize")
  } else {
    if (numHistEvents==1) names(histEvents)=c("time", "source", "sink", "migr", "resize", "growth", "migmat", "instBot", "absResize")
  }
}

endReadParFile=start

##############################  PLOTTING THE MODELED SCENARIO ######################################


#--- Graphical functions ...........................................................................

fullHeadArrow=function(x0, y0, x1, y1, length, angle, color="black",  weight=1) {
  arrows(x0, y0, x1, y1, length, angle, code=2, lty=1, col=color, lwd=weight)
  arrows(x0, y0, x1, y1, length, angle*0.80, code=2, lty=1, col=color, lwd=weight)
  arrows(x0, y0, x1, y1, length, angle*0.60, code=2, lty=1, col=color, lwd=weight)
  arrows(x0, y0, x1, y1, length, angle*0.40, code=2, lty=1, col=color, lwd=weight) 
  arrows(x0, y0, x1, y1, length, angle*0.20, code=2, lty=1, col=color, lwd=weight)
  arrows(x0, y0, x1, y1, length, angle*0.10, code=2, lty=1, col=color, lwd=weight)
}
drawTriangle=function(growth, x, y, size, aspRatio, color) {
  if (growth>0) {
    x0=x; y0=y
    x1=x-size/2; y1=y+size/2*aspRatio
    x2=x+size/2; y2=y+size/2*aspRatio
  } else {
    x0=x-size/2; y0=y
    x1=x; y1=y+size/2*aspRatio
    x2=x+size/2; y2=y
  }
  polygon(c(x0, x1, x2, x0), c(y0, y1, y2, y0), col=color)
  return(y+size/2*aspRatio)
}


#--- Computing maximum current pop size ............................................................
maxPopSize=iniPopSizes[1]
minPopSize=iniPopSizes[1]
if (length(iniPopSizes)>1){
  for (i in 2:length(iniPopSizes)) {
    if (iniPopSizes[i]>maxPopSize) maxPopSize=iniPopSizes[i];
    if (iniPopSizes[i]<minPopSize) minPopSize=iniPopSizes[i];
  }
}

numInstBot=(1:numDemes)*0
sizeInstBot=array(NA, dim=c(maxNumSpecialEvents,numDemes))
timeInstBot=array(0, dim=c(maxNumSpecialEvents,numDemes))

numMigEvents=(1:numDemes)*0
sizeMigr=array(0, dim=c(maxNumSpecialEvents,numDemes))
timeMigEvent=array(0, dim=c(maxNumSpecialEvents,numDemes))
sourceMigEvent=array(0, dim=c(maxNumSpecialEvents,numDemes))

curMigMatNum=0
numMigmatChanges=0
migMatNumbers=(1:maxNumSpecialEvents)*0
timeMigMatChanges=(1:maxNumSpecialEvents)*0


#--- Find min and max pop sizes over the whole population history ..................................
#--- and record population size change history
ps=popSizes[1,]
isGrowth=FALSE
if (numHistEvents) {
  #Need to keep track of growth rates over time
  gRates=growthRates
  prevTime=0
  numRemainingDemes=numDemes
  lastDeme=0
  for (i in 1:numHistEvents) {
    he=histEvents[i,]
    curTime=he[1]
    source=he[2]+1
    sink=he[3]+1 
    migr=he[4]
    resize=he[5]
    growth=he[6]
    migrMat=he[7]
    isInstBot=he[8]
    isAbsResize=he[9]
    
    #Record migration matrix changes
    if (migrMat!=curMigMatNum) {
      numMigmatChanges=numMigmatChanges+1
      migMatNumbers[numMigmatChanges]=migrMat
      timeMigMatChanges[numMigmatChanges]=curTime
      curMigMatNum=migrMat
    }
    
    #New routine to take care of growing demes
    if (growth!=-9999) { #if not keep growing
      if (isGrowing[sink] & growth==0)  { #Deme stops growing
          lastPopSize=popSizes[numPopSizes[sink],sink]
          newpopSize=round(lastPopSize*exp(curGrowthRates[sink]*(curTime-popSizeTimeChange[numPopSizes[sink], sink])/genTime))
          curGrowthRates[sink]=0
          isGrowing[sink]=F
          
          numPopSizes[sink]=numPopSizes[sink]+1
          popSizeTimeChange[numPopSizes[sink], sink]=curTime
          popSizes[numPopSizes[sink],sink]=newpopSize
      
      } else if (!isGrowing[sink] & growth!=0) { #deme starts growing
          isGrowing[sink]=T
          curGrowthRates[sink]=growth
          
          numPopSizes[sink]=numPopSizes[sink]+1
          popSizeTimeChange[numPopSizes[sink], sink]=curTime
          popSizes[numPopSizes[sink],sink]=popSizes[numPopSizes[sink]-1,sink]
      } else if (isGrowing[sink] & growth!=0) { #Growth is just changing and we need to adjust parameters
          lastPopSize=popSizes[numPopSizes[sink],sink]
          newpopSize=round(lastPopSize*exp(curGrowthRates[sink]*(curTime-popSizeTimeChange[numPopSizes[sink], sink])/genTime))
          
          numPopSizes[sink]=numPopSizes[sink]+1
          popSizeTimeChange[numPopSizes[sink], sink]=curTime
          popSizes[numPopSizes[sink],sink]=newpopSize
          
          curGrowthRates[sink]=growth
      }
    }
    
    #Record pop size change and compute new size
    if ((resize!=1) & (!isInstBot)) {
      oldPopSize=popSizes[numPopSizes[sink], sink]
      
      #Adding old pop size
      numPopSizes[sink]=numPopSizes[sink]+1
      popSizeTimeChange[numPopSizes[sink], sink]=curTime
      popSizes[numPopSizes[sink],sink]=oldPopSize
      
      #Adding new pop size
      numPopSizes[sink]=numPopSizes[sink]+1
      popSizeTimeChange[numPopSizes[sink], sink]=curTime
      if (!isAbsResize) {
        popSizes[numPopSizes[sink],sink]=round(oldPopSize*resize)
      } else {
        popSizes[numPopSizes[sink],sink]=round(resize)
      }
    } 
    
    #Take care of disappearing demes
    if (migr>=1 & source!=sink) {
      #If demes disappear, check it was not growing...
      if (!isGrowing[source]) {
        numPopSizes[source]=numPopSizes[source]+1
        popSizeTimeChange[numPopSizes[source], source]=curTime
        popSizes[numPopSizes[source],source]=popSizes[numPopSizes[source]-1,source]
      } else {
        endGrowthTimes[numGrowths[source],source]=curTime
        lastPopSize=popSizes[numPopSizes[source],source]
        newpopSize=round(lastPopSize*exp(curGrowthRates[source]*(curTime-startGrowthTimes[numGrowths[source], source])/genTime))
        endGrowthSize[numGrowths[source],source]=newpopSize
      }
      numRemainingDemes=numRemainingDemes-1
      if (numRemainingDemes==1) {
        lastDeme=sink
      }
    }
    
    #Record times of instantaneous bottlenecks
    if (isInstBot) {
      numInstBot[sink]=numInstBot[sink]+1
      timeInstBot[numInstBot[sink], sink]=curTime
      sizeInstBot[numInstBot[sink], sink]=1/resize
    }
    
    #Record times of migrations
    if (migr>0 & migr<1) {
      numMigEvents[sink]=numMigEvents[sink]+1
      timeMigEvent[numMigEvents[sink], sink]=curTime
      sizeMigr[numMigEvents[sink], sink]=migr
      sourceMigEvent[numMigEvents[sink], sink]=source
    }
    if (popSizes[numPopSizes[sink], sink]>maxPopSize) maxPopSize=popSizes[numPopSizes[sink], sink]
    if (popSizes[numPopSizes[sink], sink]<minPopSize) minPopSize=popSizes[numPopSizes[sink], sink]
                                                                   
    if (popSizes[numPopSizes[sink], sink]==0) 
      print(paste("Deme ", sink, " reaches size zero at time ",  curTime, ")", sep=""))
    }
    if (is.infinite(popSizes[numPopSizes[sink], sink])) print(paste("Deme ", sink, " reaches infinite size at time ",  curTime, ")", sep=""))

    #Taking care of last event
    numPopSizes[lastDeme]=numPopSizes[lastDeme]+1
    popSizeTimeChange[numPopSizes[lastDeme], lastDeme]=curTime+0.1*curTime
    popSizes[numPopSizes[lastDeme],lastDeme]=popSizes[numPopSizes[lastDeme]-1,lastDeme]
}

#-- Function to compute the circle radius for a given pop size ....................................
interpolRadius=function(curSize, minSize, maxSize, minRadius, maxRadius, logScale) {
  if(logScale) {
    if (minSize!=0) minSize=log10(minSize) else minSize=0
    if (maxSize!=0) maxSize=log10(maxSize) else maxSize=0
    if (curSize!=0) curSize=log10(curSize) else curSize=0 
  }
  curRadius=minRadius+(curSize-minSize)*(maxRadius-minRadius)/(maxSize-minSize)
  curRadius
}

names(last.he.time)=""
last.he.time=as.numeric(last.he.time)

yTimeLimit=0
maxPopSizeTimeChange=max(rbind(popSizeTimeChange, timeInstBot), na.rm=T)
if (last.he.time!=0) yTimeLimit=max(last.he.time,maxPopSizeTimeChange)*(1+propLastsegment) #Add propLastsegment to y axis after last event (to draw stuff)

#Checking for max time limit
if (fixMaxTime) {
  if (yTimeLimit>maxTimeToPlot) yTimeLimit=maxTimeToPlot
} else maxTimeToPlot=yTimeLimit

#Reorder events by their times
if (numHistEvents>1) histEvents=histEvents[order(histEvents[,1],decreasing=FALSE),] else {
  if (numHistEvents==1) histEvents=matrix(histEvents, nrow=1,  byrow = T)
}

#==============================                     ========================
#==============================   BEGIN MAIN PLOT   ========================
#==============================                     ========================

library("plotrix", verbose=F)
library("diagram", verbose=F)

if (printPDF) {
  pdf(pdfFileName, width=pdf.x.size, height=pdf.y.size)
} 

par(xpd=F, mar=c(8,6,3,2))

maxRadius=maxRadius*(numSamples+2)
minRadius=minRadius*(numSamples+2)

title=parFileName

if (genTime==1) ylabel="time (gen)" else ylabel="time (years)"

plot(x=1:numSamples, type="n", xlab="", ylab="", xlim=c(-0.5, numSamples+1.5), cex.main=0.8,
     ylim=c(0, yTimeLimit), main=title, xaxt = 'n', cex.axis=0.9, cex.lab=0.9, las=2)

mtext(side=2,ylabel, line=4)

if (usePopLabels) {
  # axis(side=1, labels=c("Mig Mat", popLabels[1:numSamples], " \nTimes"), at=0:(numSamples+1), cex.axis=0.8)
  axis(side=1, labels=c("Times", popLabels[1:numSamples], " \nMig Mat"), at=0:(numSamples+1), cex.axis=0.8)
} else {
  # axis(side=1, labels=c("Mig Mat",0:(numSamples-1), " \nTimes"), at=0:(numSamples+1), cex.axis=0.8)
  axis(side=1, labels=c("Times",0:(numSamples-1), " \nMig Mat"), at=0:(numSamples+1), cex.axis=0.8)
} 
# mtext("demes", side=1,line=4, cex=0.8)
mtext(paste("n =", sampSizes), side=1, line=1.8, at=(1:numDemes), cex=0.7)
mtext(paste("2N =", iniPopSizes), side=1, line=2.5, at=(1:numDemes), cex=0.7)
mtext(paste("FIS =", format(inbrCoeff, scientific=F, digits=2)), side=1, line=3.2, at=1:numDemes, cex=0.7)

w <- par("pin")[1]/diff(par("usr")[1:2])
h <- par("pin")[2]/diff(par("usr")[3:4])
aspRatio <- w/h


slide=timeOffset #Starting value for time slide

#--- Draw all pop size changes (10.03.21)
for (i in 1:numDemes) {
  for (j in 2:numPopSizes[i]) if (popSizes[j,i]>0) {
    
    curIniRadius=interpolRadius(popSizes[j-1,i], minPopSize, maxPopSize, minRadius, maxRadius, drawLogPopSize)
    curEndRadius=interpolRadius(popSizes[j,i], minPopSize, maxPopSize, minRadius, maxRadius, drawLogPopSize)
    
    bottomLeftX=i-curIniRadius
    bottomRightX=i+curIniRadius
    topLeftX=i-curEndRadius
    topRightX=i+curEndRadius
    
    bottomLeftY=popSizeTimeChange[j-1,i]
    bottomRightY=popSizeTimeChange[j-1,i]
    topLeftY=popSizeTimeChange[j,i]
    topRightY=popSizeTimeChange[j,i]
    polygon(c(bottomLeftX, topLeftX, topRightX, bottomRightX), c(bottomLeftY, topLeftY, topRightY, bottomRightY), 
            col=pop_col_ar[i])
    
    # rect(bottomLeft, bottomY, bottomRight, topY, col=popCol)
    text(timesPos+slide, bottomLeftY, labels=bottomLeftY, cex=timeProp, col=timeCol)
    
    slide=-slide
  }
}

#--- Handle first migration matrix .......................
curMigMatNum=0
curvature=0.0075*last.he.time

if (numMigMat) {
  if (numMigMat==1) time2DrawArrows=yTimeLimit/2 else {
    time2DrawArrows=timeMigMatChanges[1]/2
  }
  if (time2DrawArrows!=0) {
    text(migrMatPos-migrOffset, time2DrawArrows, labels=0, cex=migMatNameProp, col=migrMatCol)
    curMigMat=migMats[1][[1]]
    for (sink in 1:numSamples) {
      for (sourc in 1:numSamples) {
        if (sink!=sourc & curMigMat[sourc, sink]>0)  {
          differ=sourc-sink 
          curvedarrow(from=c(sourc, time2DrawArrows), to=c(sink,time2DrawArrows), curve=-curvature*(abs(differ)*0.55^abs(differ)), arr.adj=1, 
                      arr.pos=0.5, arr.type="triangle", arr.col=migrMatCol, lwd=1, lty=curvedArrowLTY, 
                      lcol=migrMatCol, arr.length=arrowLength)   
          if (plotMigrRates) {
            if (plotNmValues) {
              valueToPlot=round(curMigMat[sourc, sink]*ps[sourc], digits=2)   
            } else {
              valueToPlot=format(curMigMat[sourc, sink], digits=2)  
            }     
            
            if (sourc>sink) {
              xPosText=sourc-0.2*abs(differ)
              # yPosText=time2DrawArrows+aspRatio*0.15*abs(differ)
              yPosText=time2DrawArrows+aspRatio*0.1
            } else {
              xPosText=sourc+0.2*abs(differ)
              # yPosText=time2DrawArrows-aspRatio*0.15*abs(differ)
              yPosText=time2DrawArrows-aspRatio*0.1
            }
            text(xPosText, yPosText, labels=valueToPlot, cex=migrRateTextSizeCEX, col=migrMatCol) 
          }
        }
      }
    }
  }
}

getPopSize=function(time, sink, allPopSizes, timePopSizes, numChanges) {
  for (i in 2:numChanges[sink]) {
    if (timePopSizes[i, sink]>time) return(allPopSizes[i-1,sink])
  } 
  return(0)
}

#--- Draw all instantaneous bottlenecks  (10.03.21)
if (max(numInstBot)>0) {
  maxBotSize=max(sizeInstBot, na.rm=T)
  minBotSize=min(sizeInstBot, na.rm=T)
  if (maxBotSize==minBotSize) maxBotSize=4*maxBotSize
  for (i in 1:numDemes) if (numInstBot[i]) {
    for (j in 1:numInstBot[i]) {
      curRadius=interpolRadius(maxBotSize-sizeInstBot[j,i], minBotSize, maxBotSize, minRadius, maxRadius, drawLogPopSize)/2
      draw.circle(i, timeInstBot[j,i], radius = curRadius*(popSizes[j,i]-sizeInstBot[j,i])/popSizes[j,i], col=instbotColor, border=instbotColor)
      #Add inst bot intensity on top right
      xpos=i+curRadius
      if (instBotAbsSize) botText=sizeInstBot[j,i] else botText=1.0/sizeInstBot[j,i]
      text( i, timeInstBot[j,i]*(1.005), labels=format(botText,digits=1), cex=timeProp, col=textInstbotColor, pos=3)
      curPopSize=getPopSize(timeInstBot[j,i], i, popSizes, popSizeTimeChange, numPopSizes)
      curPopRadius=interpolRadius(curPopSize, minPopSize, maxPopSize, minRadius, maxRadius, drawLogPopSize)
      text(i+curPopRadius, timeInstBot[j,i], labels=format(timeInstBot[j,i],digits=1), cex=timeProp, col=textInstbotColor, pos=4)
      
    }
  }
}

#--- Draw all migration events  (10.03.21)
for (i in 1:numDemes) if (numMigEvents[i]) {
  for (j in 1:numMigEvents[i]) {
    curRadius=interpolRadius(getPopSize(timeMigEvent[j,i], i, popSizes, popSizeTimeChange, numPopSizes), minPopSize, maxPopSize, minRadius, maxRadius, drawLogPopSize)
    #Draw connecting arrows from source to sink      
    if (sourceMigEvent[j,i] > i) target = i+curRadius else target = i-curRadius
    segments(sourceMigEvent[j,i], timeMigEvent[j,i], target, timeMigEvent[j,i], col=admixCol, lty=2)
    if (i>sourceMigEvent[j,i]) {
      posArrowX=target-0.15
      posTextX=sourceMigEvent[j,i]+0.5
    }  else {
      posArrowX=target+0.15
      posTextX=sourceMigEvent[j,i]-0.5
    }
    fullHeadArrow(posArrowX, timeMigEvent[j,i], target, timeMigEvent[j,i], length=0.15, angle=20, color=admixCol)
    #Redraw time with the right color
    text(timesPos+slide, timeMigEvent[j,i], labels=timeMigEvent[j,i], cex=timeProp, col=admixCol)
    slide=-slide
    #Add admixture level on top of arrow
    text(posTextX, timeMigEvent[j,i], labels=format(sizeMigr[j,i], digits=3), cex=timeProp, col=admixCol, pos=3)
  }
}

#--- Draw all gene flow arrows (11.03.21)
if (numMigmatChanges) {
  for (i in 1:numMigmatChanges) {
    if (i<numMigmatChanges) time2DrawArrows=(timeMigMatChanges[i+1]+timeMigMatChanges[i])/2 else {
      time2DrawArrows=(timeMigMatChanges[i]+yTimeLimit)/2 
    }
    curMigMatNumber=migMatNumbers[i]
    curMigMat=migMats[curMigMatNumber+1][[1]]
    migrOffset=-migrOffset
    text(migrMatPos-migrOffset, time2DrawArrows, labels=curMigMatNumber, cex=migMatNameProp, col=migrMatCol)
    for (sink in 1:numSamples) {
      for (sourc in 1:numSamples) {
        if (sink!=sourc & curMigMat[sourc, sink]>0)  {  
          differ=sourc-sink
          curvedarrow(from=c(sourc, time2DrawArrows), to=c(sink, time2DrawArrows), curve=curvature*(abs(differ)*0.55^abs(differ)), 
                      arr.adj=1, arr.pos=0.5, arr.type="triangle", arr.col=migrMatCol, lwd=1, lty=curvedArrowLTY, 
                      lcol=migrMatCol, arr.length=arrowLength)
          if (plotMigrRates) {
            if (plotNmValues) {
              curSize=getPopSize(time2DrawArrows, sourc, popSizes, popSizeTimeChange, numPopSizes)
              valueToPlot=round(curMigMat[sourc, sink]*curSize, digits=2)  
            } else {
              valueToPlot=format(curMigMat[sourc, sink], digits=2)  
            }  
            if (sourc>sink) {
              xPosText=sourc-0.2*abs(differ)
              # yPosText=time2DrawArrows+aspRatio*0.15*abs(differ)
              yPosText=time2DrawArrows+aspRatio*0.1
            } else {
              xPosText=sourc+0.2*abs(differ)
              # yPosText=time2DrawArrows-aspRatio*0.15*abs(differ)
              yPosText=time2DrawArrows-aspRatio*0.1
            }
            text(xPosText, yPosText, labels=valueToPlot, cex=migrRateTextSizeCEX, col=migrMatCol) 
          }
        }
      }
    }
    #--- Draw separation between migration matrices numbers on the right
    segments(migrMatPos-migMatLineLength/2, timeMigMatChanges[i], 
             migrMatPos+migMatLineLength/2, timeMigMatChanges[i], lty=3, col=migrMatCol)
  }
}


#--- Draw all events on the population tree
lastTime=0
activePops=1:numSamples
numActivePops=numSamples
lastSink=-1

if (numHistEvents) {
  for (i in 1:numHistEvents) {
    # for (i in 3:3) {
     
    #Extract historical event
    he=histEvents[i,]
    he.time=he[1]
    he.source=he[2]+1 #+1 is due to the use of base 0 for deme number in fsc
    he.sink=he[3]+1
    he.migr=he[4]
    he.resize=he[5]
    he.growth=he[6]
    if(he.growth==-9999) { #handle transformed keep keyword
      he.growth=growthRates[he.sink] #Keep current growth rate
    }
    he.migrMat=he[7]
    
    if(he.migrMat==-9999) { #handle transformed keep keyword
      he.migrMat=curMigMatNum
    }
    he.instbot=he[8]
     
    #Handle population fusion .........................
    if (he.migr>=1 & he.sink!=he.source) { #This is a population fusion
      if (numActivePops==numSamples) removedPops=he.source else removedPops=c(removedPops, he.source)
      curSize=getPopSize(he.time, he.sink, popSizes, popSizeTimeChange, numPopSizes)
      curRadius=interpolRadius(curSize, minPopSize, maxPopSize, minRadius, maxRadius, drawLogPopSize)
      numActivePops=numActivePops-1
      activePops=(1:numSamples)[-removedPops]
      #Draw connecting arrows from source to sink
      if (he.source > he.sink) target = he.sink+curRadius else target = he.sink-curRadius
      # fullHeadArrow(he.source, he.time, target, he.time, length=0.15, angle=20, color = popFusionColor)
      segments(he.source, he.time, target, he.time, col = popFusionColor, lty=1) 
      #Redraw time with the right color
      text(timesPos+slide, he.time, labels=he.time, cex=timeProp, col=popFusionColor)
      slide=-slide
    }   

    lastSink=he.sink
  }
}

#-- Draw last branch
if (popSizeTimeChange[numPopSizes[lastDeme], lastDeme]<maxTimeToPlot) segments(lastDeme,popSizeTimeChange[numPopSizes[lastDeme], lastDeme], lastDeme, yTimeLimit)

#-- Draw sample ages 
for (i in 1:numDemes) {
  if (sampTimes[i]==0) {
    mtext(sampTimes[i], side=1, line=-1.2, at=i, cex=0.7, col = ageCol)
  } else text(i, sampTimes[i], labels=sampTimes[i], cex=0.7, pos=1, col = ageCol)
}



#==============================   PLOT LEGENDS IN MARGINS   ========================

#Compute space available in margin
minY.coo=grconvertY(0, from="nic", to="user")

par(xpd=NA)
#--- Draw population size scale with circles of different sizes .................
maxOrder=ceiling(log10(maxPopSize))
minOrder=floor(log10(minPopSize))
if (drawLogPopSize) popSizeRadius=10^(maxOrder:minOrder) else {
  numSteps=max(length(maxOrder:minOrder)-1, 1)
  step=(maxPopSize-minPopSize)/numSteps
  popSizeRadius=maxPopSize-step*(0:numSteps)
}
winWidth=numSamples+2
ypos=3/4*minY.coo
text(x=-winWidth/10*1.2, y=ypos, labels="Pop. \nsizes ", cex=.8, pos=2)

for (i in 1:length(popSizeRadius)) {
  curRadius=interpolRadius(popSizeRadius[i], minPopSize, maxPopSize, minRadius, maxRadius, drawLogPopSize)
#   print(curRadius)
print(i)
  if (curRadius>0) {
    xpos=-winWidth/12+(i-1)*winWidth/12
    draw.circle(xpos, ypos, radius=curRadius, col=popCol, border=popBorderCol)
  }
  text(xpos, ypos-abs(ypos)*0.1, format(popSizeRadius[i], digits=1, scientific = T), cex=0.7, pos=1, col="black")
}


if (printPDF) dev.off()


