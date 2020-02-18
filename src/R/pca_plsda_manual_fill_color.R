PlotPCA2DScore <- function(mSetObj=NA, imgName, format="png", dpi=72, 
  width=NA, pcx, pcy, reg = 0.95, show=1, grey.scale = 0){
  
  mSetObj <- MetaboAnalystR:::.get.mSet(mSetObj);
  xlabel = paste("PC",pcx, "(", round(100*mSetObj$analSet$pca$variance[pcx],1), "%)");
  ylabel = paste("PC",pcy, "(", round(100*mSetObj$analSet$pca$variance[pcy],1), "%)");
  pc1 = mSetObj$analSet$pca$x[, pcx];
  pc2 = mSetObj$analSet$pca$x[, pcy];
  text.lbls<-substr(names(pc1),1,14) # some names may be too long
  
  imgName = paste(imgName, "dpi", dpi, ".", format, sep="");
  if(is.na(width)){
    w <- 9;
  }else if(width == 0){
    w <- 7.2;
  }else{
    w <- width;
  }
  h <- w;
  
  mSetObj$imgSet$pca.score2d <- imgName;
  
  Cairo::Cairo(file = imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white");
  op<-par(mar=c(5,5,3,3));
  
  if(mSetObj$dataSet$cls.type == "disc"){
    # obtain ellipse points to the scatter plot for each category
    
    if(mSetObj$dataSet$type.cls.lbl=="integer"){
      cls <- as.factor(as.numeric(levels(mSetObj$dataSet$cls))[mSetObj$dataSet$cls]);
    }else{
      cls <- mSetObj$dataSet$cls;
    }
    
    lvs <- levels(cls);
    pts.array <- array(0, dim=c(100,2,length(lvs)));
    for(i in 1:length(lvs)){
      inx <-mSetObj$dataSet$cls == lvs[i];
      groupVar<-var(cbind(pc1[inx],pc2[inx]), na.rm=T);
      groupMean<-cbind(mean(pc1[inx], na.rm=T),mean(pc2[inx], na.rm=T));
      pts.array[,,i] <- ellipse::ellipse(groupVar, centre = groupMean, level = reg, npoints=100);
    }
    
    xrg <- range(pc1, pts.array[,1,]);
    yrg <- range(pc2, pts.array[,2,]);
    x.ext<-(xrg[2]-xrg[1])/12;
    y.ext<-(yrg[2]-yrg[1])/12;
    xlims<-c(xrg[1]-x.ext, xrg[2]+x.ext);
    ylims<-c(yrg[1]-y.ext, yrg[2]+y.ext);
    
    # To maintain color consistency, set the colors manually if there are 
    # two classes
    if (length(lvs) == 2) {
      cols <- rep(c("#4DBBD5FF", "#E64B35FF"), each = length(cls)/2)
    } else {
      cols <- MetaboAnalystR:::GetColorSchema(mSetObj, grey.scale==1)
    }
    
    uniq.cols <- unique(cols);
    
    plot(pc1, pc2, xlab=xlabel, xlim=xlims, ylim=ylims, ylab=ylabel, type='n', main="Scores Plot",
      col=cols, pch=as.numeric(mSetObj$dataSet$cls)+1); ## added
    grid(col = "lightgray", lty = "dotted", lwd = 1);
    
    # make sure name and number of the same order DO NOT USE levels, which may be different
    legend.nm <- unique(as.character(sort(cls)));
    ## uniq.cols <- unique(cols);
    
    ## BHAN: when same color is choosen; it makes an error
    if ( length(uniq.cols) > 1 ) {
      names(uniq.cols) <- legend.nm;
    }
    
    # draw ellipse
    for(i in 1:length(lvs)){
      if (length(uniq.cols) > 1) {
        polygon(pts.array[,,i], col=adjustcolor(uniq.cols[lvs[i]], alpha=0.2), border=NA);
      } else {
        polygon(pts.array[,,i], col=adjustcolor(uniq.cols, alpha=0.2), border=NA);
      }
      if(grey.scale) {
        lines(pts.array[,,i], col=adjustcolor("black", alpha=0.5), lty=2);
      }
    }
    
    pchs <- MetaboAnalystR:::GetShapeSchema(mSetObj, show, grey.scale);
    if(grey.scale) {
      cols <- rep("black", length(cols));
    }
    if(show == 1){
      text(pc1, pc2, label=text.lbls, pos=4, xpd=T, cex=0.75);
      points(pc1, pc2, pch=pchs, col=cols);
    }else{
      if(length(uniq.cols) == 1){
        points(pc1, pc2, pch=pchs, col=cols, cex=1.0);
      }else{
        if(grey.scale == 1 | (exists("shapeVec") && all(shapeVec>0))){
          points(pc1, pc2, pch=pchs, col=adjustcolor(cols, alpha.f = 0.4), cex=1.8);
        }else{
          points(pc1, pc2, pch=21, bg=adjustcolor(cols, alpha.f = 0.4), cex=2);
        }
      }
    }
    uniq.pchs <- unique(pchs);
    if(grey.scale) {
      uniq.cols <- "black";
    }
    
    if(length(lvs) < 6){
      legend("topright", legend = legend.nm, pch=uniq.pchs, col=uniq.cols);
    }else if (length(lvs) < 10){
      legend("topright", legend = legend.nm, pch=uniq.pchs, col=uniq.cols, cex=0.75);
    }else{
      legend("topright", legend = legend.nm, pch=uniq.pchs, col=uniq.cols, cex=0.5);
    }
    
  }else{
    plot(pc1, pc2, xlab=xlabel, ylab=ylabel, type='n', main="Scores Plot");
    points(pc1, pc2, pch=15, col="magenta");
    text(pc1, pc2, label=text.lbls, pos=4, col ="blue", xpd=T, cex=0.8);
  }
  par(op);
  dev.off();
  return(MetaboAnalystR:::.set.mSet(mSetObj));
}



PlotPLS2DScore <- function(mSetObj=NA, imgName, format="png", dpi=72, width=NA, inx1, inx2, reg=0.95, show=1, grey.scale=0, use.sparse=FALSE){
  
  mSetObj <- MetaboAnalystR:::.get.mSet(mSetObj);
  
  imgName = paste(imgName, "dpi", dpi, ".", format, sep="");
  if(is.na(width)){
    w <- 9;
  }else if(width == 0){
    w <- 7.2;
  }else{
    w <- width;
  }
  h <- w;
  
  mSetObj$imgSet$pls.score2d <- imgName;
  
  lv1 <- mSetObj$analSet$plsr$scores[,inx1];
  lv2 <- mSetObj$analSet$plsr$scores[,inx2];
  xlabel <- paste("Component", inx1, "(", round(100*mSetObj$analSet$plsr$Xvar[inx1]/mSetObj$analSet$plsr$Xtotvar,1), "%)");
  ylabel <- paste("Component", inx2, "(", round(100*mSetObj$analSet$plsr$Xvar[inx2]/mSetObj$analSet$plsr$Xtotvar,1), "%)");
  
  Cairo::Cairo(file = imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white");
  par(mar=c(5,5,3,3));
  text.lbls <- substr(rownames(mSetObj$dataSet$norm),1,12) # some names may be too long
  
  # obtain ellipse points to the scatter plot for each category
  
  if(mSetObj$dataSet$type.cls.lbl=="integer"){
    cls <- as.factor(as.numeric(levels(mSetObj$dataSet$cls))[mSetObj$dataSet$cls]);
  }else{
    cls <- mSetObj$dataSet$cls;
  }
  
  lvs <- levels(cls);
  pts.array <- array(0, dim=c(100,2,length(lvs)));
  for(i in 1:length(lvs)){
    inx <- mSetObj$dataSet$cls == lvs[i];
    groupVar <- var(cbind(lv1[inx],lv2[inx]), na.rm=T);
    groupMean <- cbind(mean(lv1[inx], na.rm=T),mean(lv2[inx], na.rm=T));
    pts.array[,,i] <- ellipse::ellipse(groupVar, centre = groupMean, level = reg, npoints=100);
  }
  
  xrg <- range(lv1, pts.array[,1,]);
  yrg <- range(lv2, pts.array[,2,]);
  x.ext<-(xrg[2]-xrg[1])/12;
  y.ext<-(yrg[2]-yrg[1])/12;
  xlims<-c(xrg[1]-x.ext, xrg[2]+x.ext);
  ylims<-c(yrg[1]-y.ext, yrg[2]+y.ext);
  
  ## cols = as.numeric(dataSet$cls)+1;
  # To maintain color consistency, set the colors manually if there are 
  # two classes
  if (length(lvs) == 2) {
    cols <- rep(c("#4DBBD5FF", "#E64B35FF"), each = length(cls)/2)
  } else {
    cols <- MetaboAnalystR:::GetColorSchema(mSetObj, grey.scale==1)
  }
  uniq.cols <- unique(cols);
  
  plot(lv1, lv2, xlab=xlabel, xlim=xlims, ylim=ylims, ylab=ylabel, type='n', main="Scores Plot");
  grid(col = "lightgray", lty = "dotted", lwd = 1);
  
  # make sure name and number of the same order DO NOT USE levels, which may be different
  legend.nm <- unique(as.character(sort(cls)));
  ## uniq.cols <- unique(cols);
  
  ## BHAN: when same color is choosen for black/white; it makes an error
  # names(uniq.cols) <- legend.nm;
  if (length(uniq.cols) > 1) {
    names(uniq.cols) <- legend.nm;
  }
  # draw ellipse
  for(i in 1:length(lvs)){
    if ( length(uniq.cols) > 1) {
      polygon(pts.array[,,i], col=adjustcolor(uniq.cols[lvs[i]], alpha=0.2), border=NA);
    } else {
      polygon(pts.array[,,i], col=adjustcolor(uniq.cols, alpha=0.2), border=NA);
    }
    if(grey.scale) {
      lines(pts.array[,,i], col=adjustcolor("black", alpha=0.5), lty=2);
    }
  }
  
  pchs <- MetaboAnalystR:::GetShapeSchema(mSetObj, show, grey.scale);
  if(grey.scale) {
    cols <- rep("black", length(cols));
  }
  if(show==1){ # display sample name set on
    text(lv1, lv2, label=text.lbls, pos=4, xpd=T, cex=0.75);
    points(lv1, lv2, pch=pchs, col=cols);
  }else{
    if (length(uniq.cols) == 1) {
      points(lv1, lv2, pch=pchs, col=cols, cex=1.0);
    } else {
      if(grey.scale == 1 | (exists("shapeVec") && all(shapeVec>0))){
        points(lv1, lv2, pch=pchs, col=adjustcolor(cols, alpha.f = 0.4), cex=1.8);
      }else{
        points(lv1, lv2, pch=21, bg=adjustcolor(cols, alpha.f = 0.4), cex=2);
      }
    }
  }
  
  uniq.pchs <- unique(pchs);
  if(grey.scale) {
    uniq.cols <- "black";
  }
  legend("topright", legend = legend.nm, pch=uniq.pchs, col=uniq.cols);
  
  dev.off();
  return(MetaboAnalystR:::.set.mSet(mSetObj));
}
