!	av00	01-mar-02	First compile with Gnu77 compiler for windows
!				(Thanks to Raymond Anderson for letting me know
!				about this compiler and doing initial compilations)
!	av01	14-mar-02	Var PI not used in routine GWAVE
!	av02	14-mar-02	Sub SECOND already intrinsic function
!	av03	15-mar-02	Multiple changes to include SOMNEC routines in nec2dx.exe
!	av04	16-mar-02	Status='NEW', somehow seems not to replace existing file.
!	av05	21-okt-02	Max number of loads (LOADMX) made equal to max-nr of segments.
!	av06	21-okt-02	Max number of NT cards (NETMX) increased from 30 to 99
!	av07	21-okt-02	Max number of EX cards (NSMAX) increased from 30 to 99
!	av08  	22-oct-02	Use of VSRC is uncertain, in some sources equal 10 and some 
!				equal 30 (=nr EX?). What should be new value ??? 
!	av09	??		??
!	av010	30-jan-03	Used DGJJ port of G77 compiler which delivers speed increase
!				from 30 to 60% for small segment counts
!	av011	04-sep-03	Logging of NetMX, NSMAX changed
!	av012	29-sep-03	Enable user-specified NGF file-name.
!	av013	29-sep-03	MinGW port used for both 11K segs and virtual memory usage.
!	av014	09-oct-03	Max number of segs at junction/single-seg (JMAX) increased from 30 to 60
!	av015	05-nov-04	BugFix: Use default NGF name when nothing specified.
!	av016	09-nov-06	Official Nec2 bugfix by J.Burke, see nec-list at robomod.net
!	av017	30-jan-08	VSRC (30) var also increase to netmx, see also av08
!	av018	10-oct-08	av015 did not work properly in all cases.
!
!     History:
!        Date      Change
!      -------     ----------------------------------------------
!      5/04/95     Matrix re-transposed in subroutine FACTR.
!                  FACTR and SOLVE changed for non-transposed matrix.
!
!     PROGRAM NEC(INPUT,TAPE5=INPUT,OUTPUT,TAPE11,TAPE12,TAPE13,TAPE14,
!    1TAPE15,TAPE16,TAPE20,TAPE21)
!
!     NUMERICAL ELECTROMAGNETICS CODE (NEC2)  DEVELOPED AT LAWRENCE
!     LIVERMORE LAB., LIVERMORE, CA.  (CONTACT G. BURKE AT 510-422-8414
!     FOR PROBLEMS WITH THE NEC CODE.)
!     FILE CREATED 4/11/80.
!
!                ***********NOTICE**********
!     THIS COMPUTER CODE MATERIAL WAS PREPARED AS AN ACCOUNT OF WORK
!     SPONSORED BY THE UNITED STATES GOVERNMENT.  NEITHER THE UNITED
!     STATES NOR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
!     THEIR EMPLOYEES, NOR ANY OF THEIR CONTRACTORS, SUBCONTRACTORS, OR
!     THEIR EMPLOYEES, MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR
!     ASSUMES ANY LEGAL LIABILITY OR RESPONSIBILITY FOR THE ACCURACY,
!     COMPLETENESS OR USEFULNESS OF ANY INFORMATION, APPARATUS, PRODUCT
!     OR PROCESS DISCLOSED, OR REPRESENTS THAT ITS USE WOULD NOT
!     INFRINGE PRIVATELY-OWNED RIGHTS.
!
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'	! Declares MAXSEG,MAXMAT,LOADMX,NETMX and NSMAX
					! AV05,AV06,AV07

      PARAMETER (IRESRV=MAXMAT**2)

      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER AIN*2,ATST*2,INFILE*80,OUTFILE*80
	
!***
      REAL*8 HPOL,PNET
      REAL  STARTTIME, ENDTIME, ELAPSED
      REAL  TIM, TIM1, TIM2
      REAL*8 TMP1

!      CHARACTER INMSG*48,OUTMSG*40
!      INTEGER*2 GPWNXY(2)
!      LOGICAL*4 GetPut,LGTPT

	integer*2	llneg

      COMPLEX*16  CM,FJ,VSANT,ETH,EPH,ZRATI,CUR,CURI,ZARRAY,ZRATI2
      COMPLEX*16  EX,EY,EZ,ZPED,VQD,VQDS,T1,Y11A,Y12A,EPSC,U,U2,XX1,XX2
      COMPLEX*16  AR1,AR2,AR3,EPSCF,FRATI
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     -ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     -ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /CMB/CM(IRESRV)
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,
     -ICASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      COMMON/SAVE/EPSR,SIG,SCRWLT,SCRWRT,FMHZ,IP(2*MAXSEG),KCOM
      COMMON/CSAVE/COM(19,5)
      COMMON /CRNT/ AIR(MAXSEG),AII(MAXSEG),BIR(MAXSEG),BII(MAXSEG),
     -CIR(MAXSEG),CII(MAXSEG),CUR(3*MAXSEG)
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     -KSYMP,IFAR,IPERF
      COMMON /ZLOAD/ ZARRAY(MAXSEG),NLOAD,NLODF
      COMMON/YPARM/Y11A(5),Y12A(20),NCOUP,ICOUP,NCTAG(5),NCSEG(5)
      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      COMMON/VSORC/VQD(nsmax),VSANT(nsmax),VQDS(nsmax),IVQD(nsmax),
     -ISANT(nsmax),IQDS(nsmax),NVQD,NSANT,NQDS			! av07

      COMMON/NETCX/ZPED,PIN,PNLS,X11R(netmx),X11I(netmx),X12R(netmx),
     -X12I(netmx),X22R(netmx),X22I(netmx),NTYP(netmx),ISEG1(netmx),
     -ISEG2(netmx),NEQ,NPEQ,NEQ2,NONET,NTSOL,NPRINT,MASYM	! av06

      COMMON/FPAT/THETS,PHIS,DTH,DPH,RFLD,GNOR,CLT,CHT,EPSR2,SIG2,
     -XPR6,PINR,PNLR,PLOSS,XNR,YNR,ZNR,DXNR,DYNR,DZNR,NTH,NPH,IPD,IAVP,
     -INOR,IAX,IXTYP,NEAR,NFEH,NRX,NRY,NRZ
      COMMON /GGRID/ AR1(11,10,4),AR2(17,5,4),AR3(9,8,4),EPSCF,DXA(3),
     -DYA(3),XSA(3),YSA(3),NXA(3),NYA(3)
      COMMON/GWAV/U,U2,XX1,XX2,R1,R2,ZMH,ZPH
!***
      COMMON /PLOT/ IPLP1,IPLP2,IPLP3,IPLP4
!***
      DIMENSION CAB(1),SAB(1),X2(1),Y2(1),Z2(1)

      DIMENSION LDTYP(loadmx),LDTAG(loadmx),LDTAGF(loadmx),
     -LDTAGT(loadmx),ZLR(loadmx),ZLI(loadmx),ZLC(loadmx)	! av05

      DIMENSION ATST(22),PNET(6),HPOL(3),IX(2*MAXSEG)
      DIMENSION FNORM(200)
      DIMENSION T1X(1),T1Y(1),T1Z(1),T2X(1),T2Y(1),T2Z(1)
!***
      DIMENSION XTEMP(MAXSEG),YTEMP(MAXSEG),ZTEMP(MAXSEG),
     &SITEMP(MAXSEG),BITEMP(MAXSEG)
      EQUIVALENCE (CAB,ALP),(SAB,BET),(X2,SI),(Y2,ALP),(Z2,BET)
      EQUIVALENCE (T1X,SI),(T1Y,ALP),(T1Z,BET),(T2X,ICON1),(T2Y,ICON2),
     -(T2Z,ITAG)
      DATA ATST/'CE','FR','LD','GN','EX','NT','XQ','NE','GD','RP','CM',
     -'NX','EN','TL','PT','KH','NH','PQ','EK','WG','CP','PL'/
      DATA HPOL/6HLINEAR,5HRIGHT,4HLEFT/
      DATA PNET/6H      ,2H  ,6HSTRAIG,2HHT,6HCROSSE,1HD/
      DATA TA/1.745329252D-02/,CVEL/299.8/

      DATA NORMF/200/							

	INCLUDE 'g77port.inc'	! Sets G77 port and version used to compile/link.

      print *, ''
      print *, 'Numerical Electromagnetics Code, ',
     &'double precision version (nec2d)'
      print *, 'developed at Lawrence Livermore Lab., ',
     &'Livermore, CA., by G. Burke'
      print *, '(burke@icdc.llnl.gov) and A. Poggio.'
      Write(*,*)
     & 'Fortran file was created 4/11/80, changed: Jan 15, 96, by'
      Write(*,*)
     & 'J. Bergervoet (bergervo@prl.philips.nl)'
      print *, 'Maximum number of segments in core : MAXMAT=',MAXMAT
      If(MaxSeg.ne.MaxMat) 
     &print *, 'Maximum when using swap files      : MAXSEG=',MAXSEG

      print *, ''
	print *, 
     & 'Merged nec2d/som2d file created by Arie Voors. (4nec2@gmx.net)'
	print *,'Build 2.7  30-jan-08  ',
     & '(maxLD=',loadmx,', MaxEX=',nsmax,', MaxTL=',netmx,')'	! av011
	print *,'Using ',G77PORT		! 'XX port for G77 version YY'
      print *, ''

!***VAX
706   CONTINUE
      WRITE(*,700)
700   FORMAT(' ENTER NAME OF INPUT FILE >',$)
      READ(*,701,ERR=706,END=708) INFILE				! av03
701   FORMAT(A)
      OPEN (UNIT=2,FILE=INFILE,STATUS='OLD',ERR=702)

707   CONTINUE
      WRITE(*,703)
703   FORMAT(' ENTER NAME OF OUTPUT FILE >',$)
      READ(*,701,ERR=707,end=706) OUTFILE				! av03
      OPEN (UNIT=3,FILE=OUTFILE,STATUS='UNKNOWN',ERR=704)
      GO TO 705

702	print *, 'Error opening input-file:',infile		! av03
      GO TO 706

704	print *, 'Error opening output-file:',outfile		! av03
      GO TO 707

708	stop

705   CONTINUE
      print *,''
      CALL SECOND(STARTTIME)
      FJ=(0.,1.)
      LD=MAXSEG
1     KCOM=0
!***
      IFRTIMW=0
      IFRTIMP=0
!***
2     KCOM=KCOM+1
      IF (KCOM.GT.5) KCOM=5
      READ(2,125)AIN,(COM(I,KCOM),I=1,19)
      CALL UPCASE(AIN,AIN,LAIN)
      IF(KCOM.GT.1)GO TO 3

      WRITE(3,126)
      WRITE(3,127)
      WRITE(3,128)

3     WRITE(3,129) (COM(I,KCOM),I=1,19)
      IF (AIN.EQ.ATST(11)) GO TO 2
      IF (AIN.EQ.ATST(1)) GO TO 4

      WRITE(3,130)
      STOP

4     CONTINUE
      DO 5 I=1,LD
5     ZARRAY(I)=(0.,0.)
      MPCNT=0
      IMAT=0
!
!     SET UP GEOMETRY DATA IN SUBROUTINE DATAGN
!
      CALL DATAGN
      IFLOW=1
      IF(IMAT.EQ.0)GO TO 326
!
!     CORE ALLOCATION FOR ARRAYS B, C, AND D FOR N.G.F. SOLUTION
!
      NEQ=N1+2*M1
      NEQ2=N-N1+2*(M-M1)+NSCON+2*NPCON
      CALL FBNGF(NEQ,NEQ2,IRESRV,IB11,IC11,ID11,IX11)
      GO TO 6

326   NEQ=N+2*M
      NEQ2=0
      IB11=1
      IC11=1
      ID11=1
      IX11=1
      ICASX=0
6     NPEQ=NP+2*MP
      WRITE(3,135)
!
!     DEFAULT VALUES FOR INPUT PARAMETERS AND FLAGS
!
!***
      IPLP1=0
      IPLP2=0
      IPLP3=0
      IPLP4=0
!***
      IGO=1
      FMHZS=CVEL
      NFRQ=1
      RKH=1.
      IEXK=0
      IXTYP=0
      NLOAD=0
      NONET=0
      NEAR=-1
      IPTFLG=-2
      IPTFLQ=-1
      IFAR=-1
      ZRATI=(1.,0.)
      IPED=0
      IRNGF=0
      NCOUP=0
      ICOUP=0
	llneg = 0	! av03, Default = No freq-loop/Neg-sigma

      IF(ICASX.GT.0)GO TO 14
      FMHZ=CVEL
      NLODF=0
      KSYMP=1
      NRADL=0
      IPERF=0
!
!     MAIN INPUT SECTION - STANDARD READ STATEMENT - JUMPS TO APPRO-
!     PRIATE SECTION FOR SPECIFIC PARAMETER SET UP
!
14    CALL READMN(2,AIN,ITMP1,ITMP2,ITMP3,ITMP4,TMP1,TMP2,TMP3,TMP4,
     &TMP5,TMP6)
      MPCNT=MPCNT+1
      WRITE(3,137) MPCNT,AIN,ITMP1,ITMP2,ITMP3,ITMP4,TMP1,TMP2,TMP3,
     1TMP4,TMP5,TMP6
      IF (AIN.EQ.ATST(2)) GO TO 16	! FR
      IF (AIN.EQ.ATST(3)) GO TO 17	! LD
      IF (AIN.EQ.ATST(4)) GO TO 21	! GN
      IF (AIN.EQ.ATST(5)) GO TO 24	! EX
      IF (AIN.EQ.ATST(6)) GO TO 28	! NT
      IF (AIN.EQ.ATST(14)) GO TO 28	! TL
      IF (AIN.EQ.ATST(15)) GO TO 31	! PT
      IF (AIN.EQ.ATST(18)) GO TO 319 ! PQ
      IF (AIN.EQ.ATST(7)) GO TO 37	! XQ
      IF (AIN.EQ.ATST(8)) GO TO 32	! NE
      IF (AIN.EQ.ATST(17)) GO TO 208 ! NH
      IF (AIN.EQ.ATST(9)) GO TO 34	! GD
      IF (AIN.EQ.ATST(10)) GO TO 36	! RP
      IF (AIN.EQ.ATST(16)) GO TO 305 ! KH
      IF (AIN.EQ.ATST(19)) GO TO 320 ! EK
      IF (AIN.EQ.ATST(12)) GO TO 1	! NX
      IF (AIN.EQ.ATST(20)) GO TO 322 ! WG
      IF (AIN.EQ.ATST(21)) GO TO 304 ! CP
!***
      IF (AIN.EQ.ATST(22)) GO TO 330 ! PL ???
!***
      IF (AIN.NE.ATST(13)) GO TO 15	! EN

      CALL SECOND(ENDTIME)
      ELAPSED=ENDTIME-STARTTIME
      WRITE(3,201) ELAPSED
      STOP
15    WRITE(3,138)
      STOP
!
!     FREQUENCY PARAMETERS
!
16    IFRQ=ITMP1
      IF(ICASX.EQ.0)GO TO 8
      WRITE(3,303) AIN
      STOP

8     NFRQ=ITMP2
      IF (NFRQ.EQ.0) NFRQ=1
      FMHZ=TMP1
      DELFRQ=TMP2
      IF(IPED.EQ.1)ZPNORM=0.
      IGO=1
      IFLOW=1
      GO TO 14
!
!     MATRIX INTEGRATION LIMIT
!
305   RKH=TMP1
      IF(IGO.GT.2)IGO=2
      IFLOW=1
      GO TO 14
!
!     EXTENDED THIN WIRE KERNEL OPTION
!
320   IEXK=1
      IF(ITMP1.EQ.-1)IEXK=0
      IF(IGO.GT.2)IGO=2
      IFLOW=1
      GO TO 14
!
!     MAXIMUM COUPLING BETWEEN ANTENNAS
!
304   IF(IFLOW.NE.2)NCOUP=0
      ICOUP=0
      IFLOW=2
      IF(ITMP2.EQ.0)GO TO 14
      NCOUP=NCOUP+1
      IF(NCOUP.GT.5)GO TO 312
      NCTAG(NCOUP)=ITMP1
      NCSEG(NCOUP)=ITMP2
      IF(ITMP4.EQ.0)GO TO 14
      NCOUP=NCOUP+1
      IF(NCOUP.GT.5)GO TO 312
      NCTAG(NCOUP)=ITMP3
      NCSEG(NCOUP)=ITMP4
      GO TO 14
312   WRITE(3,313)
      STOP
!
!     LOADING PARAMETERS
!
17    IF (IFLOW.EQ.3) GO TO 18
      NLOAD=0
      IFLOW=3
      IF (IGO.GT.2) IGO=2
      IF (ITMP1.EQ.(-1)) GO TO 14
18    NLOAD=NLOAD+1
      IF (NLOAD.LE.LOADMX) GO TO 19
      WRITE(3,139)
      STOP

19    LDTYP(NLOAD)=ITMP1
      LDTAG(NLOAD)=ITMP2
      IF (ITMP4.EQ.0) ITMP4=ITMP3
      LDTAGF(NLOAD)=ITMP3
      LDTAGT(NLOAD)=ITMP4
      IF (ITMP4.GE.ITMP3) GO TO 20
      WRITE(3,140)  NLOAD,ITMP3,ITMP4
      STOP

20    ZLR(NLOAD)=TMP1
      ZLI(NLOAD)=TMP2
      ZLC(NLOAD)=TMP3
      GO TO 14
!
!     GROUND PARAMETERS UNDER THE ANTENNA
!
21    IFLOW=4
      IF(ICASX.EQ.0)GO TO 10
      WRITE(3,303) AIN
      STOP

10    IF (IGO.GT.2) IGO=2
      IF (ITMP1.NE.(-1)) GO TO 22
      KSYMP=1
      NRADL=0
      IPERF=0
      GO TO 14

22    IPERF=ITMP1
      NRADL=ITMP2
      KSYMP=2
      EPSR=TMP1
      SIG=TMP2
      IF (NRADL.EQ.0) GO TO 23
      IF(IPERF.NE.2)GO TO 314
      WRITE(3,390)
      STOP

314   SCRWLT=TMP3
      SCRWRT=TMP4
      GO TO 14

23    EPSR2=TMP3
      SIG2=TMP4
      CLT=TMP5
      CHT=TMP6
      GO TO 14
!
!     EXCITATION PARAMETERS
!
24    IF (IFLOW.EQ.5) GO TO 25
      NSANT=0
      NVQD=0
      IPED=0
      IFLOW=5
      IF (IGO.GT.3) IGO=3
25    MASYM=ITMP4/10
      IF (ITMP1.GT.0.AND.ITMP1.NE.5) GO TO 27
      IXTYP=ITMP1
      NTSOL=0
      IF(IXTYP.EQ.0)GO TO 205
      NVQD=NVQD+1
      IF(NVQD.GT.NSMAX)GO TO 206
      IVQD(NVQD)=ISEGNO(ITMP2,ITMP3)
      VQD(NVQD)=DCMPLX(TMP1,TMP2)
      IF(ABS(VQD(NVQD)).LT.1.D-20)VQD(NVQD)=(1.,0.)
      GO TO 207
205   NSANT=NSANT+1
      IF (NSANT.LE.NSMAX) GO TO 26
206   WRITE(3,141)
      STOP

26    ISANT(NSANT)=ISEGNO(ITMP2,ITMP3)
      VSANT(NSANT)=DCMPLX(TMP1,TMP2)
      IF (ABS(VSANT(NSANT)).LT.1.D-20) VSANT(NSANT)=(1.,0.)
207   IPED=ITMP4-MASYM*10
      ZPNORM=TMP3
      IF (IPED.EQ.1.AND.ZPNORM.GT.0) IPED=2
      GO TO 14

27    IF (IXTYP.EQ.0.OR.IXTYP.EQ.5) NTSOL=0
      IXTYP=ITMP1
      NTHI=ITMP2
      NPHI=ITMP3
      XPR1=TMP1
      XPR2=TMP2
      XPR3=TMP3
      XPR4=TMP4
      XPR5=TMP5
      XPR6=TMP6
      NSANT=0
      NVQD=0
      THETIS=XPR1
      PHISS=XPR2
      GO TO 14
!
!     NETWORK PARAMETERS
!
28    IF (IFLOW.EQ.6) GO TO 29
      NONET=0
      NTSOL=0
      IFLOW=6
      IF (IGO.GT.3) IGO=3
      IF (ITMP2.EQ.(-1)) GO TO 14

29    NONET=NONET+1
      IF (NONET.LE.NETMX) GO TO 30
      WRITE(3,142)
      STOP

30    NTYP(NONET)=2
      IF (AIN.EQ.ATST(6)) NTYP(NONET)=1
      ISEG1(NONET)=ISEGNO(ITMP1,ITMP2)
      ISEG2(NONET)=ISEGNO(ITMP3,ITMP4)
      X11R(NONET)=TMP1
      X11I(NONET)=TMP2
      X12R(NONET)=TMP3
      X12I(NONET)=TMP4
      X22R(NONET)=TMP5
      X22I(NONET)=TMP6
      IF (NTYP(NONET).EQ.1.OR.TMP1.GT.0.) GO TO 14
      NTYP(NONET)=3
      X11R(NONET)=-TMP1
      GO TO 14
!***
!
!     PLOT FLAGS
!
330   IPLP1=ITMP1
      IPLP2=ITMP2
      IPLP3=ITMP3
      IPLP4=ITMP4
      OPEN (UNIT=8,FILE='PLTDAT.NEC',STATUS='UNKNOWN',ERR=14) ! av04
!***
      GO TO 14
!
!     PRINT CONTROL FOR CURRENT
!
31    IPTFLG=ITMP1
      IPTAG=ITMP2
      IPTAGF=ITMP3
      IPTAGT=ITMP4
      IF(ITMP3.EQ.0.AND.IPTFLG.NE.-1)IPTFLG=-2
      IF (ITMP4.EQ.0) IPTAGT=IPTAGF
      GO TO 14
!
!     WRITE CONTROL FOR CHARGE
!
319   IPTFLQ=ITMP1
      IPTAQ=ITMP2
      IPTAQF=ITMP3
      IPTAQT=ITMP4
      IF(ITMP3.EQ.0.AND.IPTFLQ.NE.-1)IPTFLQ=-2
      IF(ITMP4.EQ.0)IPTAQT=IPTAQF
      GO TO 14
!
!     NEAR FIELD CALCULATION PARAMETERS
!
208   NFEH=1
      GO TO 209
32    NFEH=0
209   IF (.NOT.(IFLOW.EQ.8.AND.NFRQ.NE.1)) GO TO 33
      WRITE(3,143)
33    NEAR=ITMP1
      NRX=ITMP2
      NRY=ITMP3
      NRZ=ITMP4
      XNR=TMP1
      YNR=TMP2
      ZNR=TMP3
      DXNR=TMP4
      DYNR=TMP5
      DZNR=TMP6
      IFLOW=8
      IF (NFRQ.NE.1) GO TO 14
      GO TO (41,46,53,71,72), IGO
!
!     GROUND REPRESENTATION
!
34    EPSR2=TMP1
      SIG2=TMP2
      CLT=TMP3
      CHT=TMP4
      IFLOW=9
      GO TO 14
!
!     STANDARD OBSERVATION ANGLE PARAMETERS
!
36    IFAR=ITMP1
      NTH=ITMP2
      NPH=ITMP3
      IF (NTH.EQ.0) NTH=1
      IF (NPH.EQ.0) NPH=1
      IPD=ITMP4/10
      IAVP=ITMP4-IPD*10
      INOR=IPD/10
      IPD=IPD-INOR*10
      IAX=INOR/10
      INOR=INOR-IAX*10
      IF (IAX.NE.0) IAX=1
      IF (IPD.NE.0) IPD=1
      IF (NTH.LT.2.OR.NPH.LT.2) IAVP=0
      IF (IFAR.EQ.1) IAVP=0
      THETS=TMP1
      PHIS=TMP2
      DTH=TMP3
      DPH=TMP4
      RFLD=TMP5
      GNOR=TMP6
      IFLOW=10
      GO TO (41,46,53,71,78), IGO
!
!     WRITE NUMERICAL GREEN'S FUNCTION TAPE
!
322   IFLOW=12
      IF(ICASX.EQ.0)GO TO 301
      WRITE(3,302)
      STOP
301   IRNGF=IRESRV/2
      GO TO (41,46,52,52,52),IGO
!
!     EXECUTE CARD  -  CALC. INCLUDING RADIATED FIELDS
!
37    IF (IFLOW.EQ.10.AND.ITMP1.EQ.0) GO TO 14
      IF (NFRQ.EQ.1.AND.ITMP1.EQ.0.AND.IFLOW.GT.7) GO TO 14
      IF (ITMP1.NE.0) GO TO 39
      IF (IFLOW.GT.7) GO TO 38
      IFLOW=7
      GO TO 40

38    IFLOW=11
      GO TO 40

39    IFAR=0
      RFLD=0.
      IPD=0
      IAVP=0
      INOR=0
      IAX=0
      NTH=91
      NPH=1
      THETS=0.
      PHIS=0.
      DTH=1.0
      DPH=0.
      IF (ITMP1.EQ.2) PHIS=90.
      IF (ITMP1.NE.3) GO TO 40
      NPH=2
      DPH=90.
40    GO TO (41,46,53,71,78), IGO
!
!     END OF THE MAIN INPUT SECTION
!
!     BEGINNING OF THE FREQUENCY DO LOOP
!
41    MHZ=1
!***
      IF(N.EQ.0 .OR. IFRTIMW .EQ. 1)GO TO 406
      IFRTIMW=1
      DO 445 I=1,N
         XTEMP(I)=X(I)
         YTEMP(I)=Y(I)
         ZTEMP(I)=Z(I)
         SITEMP(I)=SI(I)
         BITEMP(I)=BI(I)
445   CONTINUE

406   IF(M.EQ.0 .OR. IFRTIMP .EQ. 1)GO TO 407
      IFRTIMP=1
      J=LD+1
      DO 545 I=1,M
         J=J-1
         XTEMP(J)=X(J)
         YTEMP(J)=Y(J)
         ZTEMP(J)=Z(J)
         BITEMP(J)=BI(J)
545   CONTINUE
407   CONTINUE
      FMHZ1=FMHZ
!***
!     CORE ALLOCATION FOR PRIMARY INTERACTON MATRIX.  (A)
      IF(IMAT.EQ.0)CALL FBLOCK(NPEQ,NEQ,IRESRV,IRNGF,IPSYM)
42    IF (MHZ.EQ.1) GO TO 44
      IF (IFRQ.EQ.1) GO TO 43
!      FMHZ=FMHZ+DELFRQ
!***
      FMHZ=FMHZ1+(MHZ-1)*DELFRQ
      GO TO 44
43    FMHZ=FMHZ*DELFRQ
44    FR=FMHZ/CVEL
!***
      WLAM=CVEL/FMHZ		! wavl=299.8/freq
      WRITE(3,145)  FMHZ,WLAM
      WRITE(3,196) RKH
      IF(IEXK.EQ.1)WRITE(3,321)
!     FREQUENCY SCALING OF GEOMETRIC PARAMETERS
!***      FMHZS=FMHZ
      IF(N.EQ.0)GO TO 306
      DO 45 I=1,N
!***
      X(I)=XTEMP(I)*FR
      Y(I)=YTEMP(I)*FR
      Z(I)=ZTEMP(I)*FR
      SI(I)=SITEMP(I)*FR
45    BI(I)=BITEMP(I)*FR
!***
306   IF(M.EQ.0)GO TO 307
      FR2=FR*FR
      J=LD+1
      DO 245 I=1,M
      J=J-1
!***
      X(J)=XTEMP(J)*FR
      Y(J)=YTEMP(J)*FR
      Z(J)=ZTEMP(J)*FR
245   BI(J)=BITEMP(J)*FR2
!***
307   IGO=2

!     STRUCTURE SEGMENT LOADING

46    WRITE(3,146)
      IF(NLOAD.NE.0) CALL LOAD(LDTYP,LDTAG,LDTAGF,LDTAGT,ZLR,ZLI,ZLC)

      IF(NLOAD.EQ.0.AND.NLODF.EQ.0)WRITE(3,147)
      IF(NLOAD.EQ.0.AND.NLODF.NE.0)WRITE(3,327)

!     GROUND PARAMETER

      WRITE(3,148)			! Antenna environment
      IF (KSYMP.EQ.1) GO TO 49
      FRATI=(1.,0.)
      IF (IPERF.EQ.1) GO TO 48

      IF (SIG.LT.0.) then		! av03, Negative sigma ?
	   llneg = 1			! Set flag
         SIG=-SIG/(59.96*WLAM)	! Make positive
	endif

      EPSC=DCMPLX(EPSR,-SIG*WLAM*59.96)
      ZRATI=1./SQRT(EPSC)
      U=ZRATI
      U2=U*U
      IF (NRADL.EQ.0) GO TO 47
      SCRWL=SCRWLT/WLAM
      SCRWR=SCRWRT/WLAM
      T1=FJ*2367.067D+0/DFLOAT(NRADL)
      T2=SCRWR*DFLOAT(NRADL)
      WRITE(3,170)  NRADL,SCRWLT,SCRWRT
      WRITE(3,149)
47    IF(IPERF.EQ.2)GO TO 328		! Somnec ground ?

      WRITE(3,391)			! Finite ground
      GO TO 329

!******************************************************************************
!	Include SomNec calculations
!******************************************************************************

328	if (llneg.le.1) then		! Single or first step ?
	   if (llneg.eq.1) llneg=2	! If negative, only once
   	   call som2d (fmhz,epsr,sig) ! Get SomNec data, av03
	endif

      FRATI=(EPSC-1.)/(EPSC+1.)
      IF(ABS((EPSCF-EPSC)/EPSC).LT.1.D-3)GO TO 400

      WRITE(3,393) EPSCF,EPSC		! Error in ground param's
      STOP

400   WRITE(3,392)			! Sommerfeld ground
329   WRITE(3,150)  EPSR,SIG,EPSC	! Rel-diel-C, conduct, compl-diel-C
      GO TO 50

48    WRITE(3,151)	! Perfect ground
      GO TO 50

49    WRITE(3,152)	! Free space
50    CONTINUE
! * * *
!     FILL AND FACTOR PRIMARY INTERACTION MATRIX
!
      CALL SECOND (TIM1)
      IF(ICASX.NE.0)GO TO 324
      CALL CMSET(NEQ,CM,RKH,IEXK)
      CALL SECOND (TIM2)
      TIM=TIM2-TIM1
      CALL FACTRS(NPEQ,NEQ,CM,IP,IX,11,12,13,14)
      GO TO 323
!
!     N.G.F. - FILL B, C, AND D AND FACTOR D-C(INV(A)B)
!
! ****
324   IF(NEQ2.EQ.0)GO TO 333
! ****
      CALL CMNGF(CM(IB11),CM(IC11),CM(ID11),NPBX,NEQ,NEQ2,RKH,IEXK)
      CALL SECOND (TIM2)
      TIM=TIM2-TIM1
      CALL FACGF(CM,CM(IB11),CM(IC11),CM(ID11),CM(IX11),IP,IX,NP,N1,MP,
     1M1,NEQ,NEQ2)
323   CALL SECOND (TIM1)
      TIM2=TIM1-TIM2
      WRITE(3,153)  TIM,TIM2
333   IGO=3
      NTSOL=0
      IF(IFLOW.NE.12)GO TO 53
!     WRITE N.G.F. FILE
52    CALL GFOUT
      GO TO 14
!
!     EXCITATION SET UP (RIGHT HAND SIDE, -E INC.)
!
53    NTHIC=1
      NPHIC=1
      INC=1
      NPRINT=0
54    IF (IXTYP.EQ.0.OR.IXTYP.EQ.5) GO TO 56
      IF (IPTFLG.LE.0.OR.IXTYP.EQ.4) WRITE(3,154)
      TMP5=TA*XPR5
      TMP4=TA*XPR4
      IF (IXTYP.NE.4) GO TO 55
      TMP1=XPR1/WLAM
      TMP2=XPR2/WLAM
      TMP3=XPR3/WLAM
      TMP6=XPR6/(WLAM*WLAM)
      WRITE(3,156)  XPR1,XPR2,XPR3,XPR4,XPR5,XPR6
      GO TO 56
55    TMP1=TA*XPR1
      TMP2=TA*XPR2
      TMP3=TA*XPR3
      TMP6=XPR6
      IF (IPTFLG.LE.0) WRITE(3,155)  XPR1,XPR2,XPR3,HPOL(IXTYP),XPR6
56    CALL ETMNS (TMP1,TMP2,TMP3,TMP4,TMP5,TMP6,IXTYP,CUR)
!
!     MATRIX SOLVING  (NETWK CALLS SOLVES)
!
      IF (NONET.EQ.0.OR.INC.GT.1) GO TO 60
      WRITE(3,158)
      ITMP3=0
      ITMP1=NTYP(1)
      DO 59 I=1,2
      IF (ITMP1.EQ.3) ITMP1=2
      IF (ITMP1.EQ.2) WRITE(3,159)
      IF (ITMP1.EQ.1) WRITE(3,160)
      DO 58 J=1,NONET
      ITMP2=NTYP(J)
      IF ((ITMP2/ITMP1).EQ.1) GO TO 57
      ITMP3=ITMP2
      GO TO 58
57    ITMP4=ISEG1(J)
      ITMP5=ISEG2(J)
      IF (ITMP2.GE.2.AND.X11I(J).LE.0.) X11I(J)=WLAM*SQRT((X(ITMP5)-
     1 X(ITMP4))**2+(Y(ITMP5)-Y(ITMP4))**2+(Z(ITMP5)-Z(ITMP4))**2)
      WRITE(3,157)  ITAG(ITMP4),ITMP4,ITAG(ITMP5),ITMP5,X11R(J),X11
     1I(J),X12R(J),X12I(J),X22R(J),X22I(J),PNET(2*ITMP2-1),PNET(2*ITMP2)
58    CONTINUE
      IF (ITMP3.EQ.0) GO TO 60
      ITMP1=ITMP3
59    CONTINUE
60    CONTINUE
      IF (INC.GT.1.AND.IPTFLG.GT.0) NPRINT=1
      CALL NETWK(CM,CM(IB11),CM(IC11),CM(ID11),IP,CUR)
      NTSOL=1
      IF (IPED.EQ.0) GO TO 61
      ITMP1=MHZ+4*(MHZ-1)
      IF (ITMP1.GT.(NORMF-3)) GO TO 61
      FNORM(ITMP1)=DREAL(ZPED)
      FNORM(ITMP1+1)=DIMAG(ZPED)
      FNORM(ITMP1+2)=ABS(ZPED)
      FNORM(ITMP1+3)=CANG(ZPED)
      IF (IPED.EQ.2) GO TO 61
      IF (FNORM(ITMP1+2).GT.ZPNORM) ZPNORM=FNORM(ITMP1+2)
61    CONTINUE
!
!     PRINTING STRUCTURE CURRENTS
!
      IF(N.EQ.0)GO TO 308
      IF (IPTFLG.EQ.(-1)) GO TO 63
      IF (IPTFLG.GT.0) GO TO 62
      WRITE(3,161)
      WRITE(3,162)
      GO TO 63
62    IF (IPTFLG.EQ.3.OR.INC.GT.1) GO TO 63
      WRITE(3,163)  XPR3,HPOL(IXTYP),XPR6
63    PLOSS=0.
      ITMP1=0
      JUMP=IPTFLG+1
      DO 69 I=1,N
      CURI=CUR(I)*WLAM
      CMAG=ABS(CURI)
      PH=CANG(CURI)
      IF (NLOAD.EQ.0.AND.NLODF.EQ.0) GO TO 64
      IF (ABS(DREAL(ZARRAY(I))).LT.1.D-20) GO TO 64
      PLOSS=PLOSS+.5*CMAG*CMAG*DREAL(ZARRAY(I))*SI(I)
64    IF (JUMP) 68,69,65
65    IF (IPTAG.EQ.0) GO TO 66
      IF (ITAG(I).NE.IPTAG) GO TO 69
66    ITMP1=ITMP1+1
      IF (ITMP1.LT.IPTAGF.OR.ITMP1.GT.IPTAGT) GO TO 69
      IF (IPTFLG.EQ.0) GO TO 68
      IF (IPTFLG.LT.2.OR.INC.GT.NORMF) GO TO 67
      FNORM(INC)=CMAG
      ISAVE=I
67    IF (IPTFLG.NE.3) WRITE(3,164)  XPR1,XPR2,CMAG,PH,I
      GO TO 69
68    WRITE(3,165)  I,ITAG(I),X(I),Y(I),Z(I),SI(I),CURI,CMAG,PH
!***
      IF(IPLP1 .NE. 1) GO TO 69
      IF(IPLP2 .EQ. 1) WRITE(8,*) CURI
      IF(IPLP2 .EQ. 2) WRITE(8,*) CMAG,PH
!***
69    CONTINUE
      IF(IPTFLQ.EQ.(-1))GO TO 308
      WRITE(3,315)
      ITMP1=0
      FR=1.D-6/FMHZ
      DO 316 I=1,N
      IF(IPTFLQ.EQ.(-2))GO TO 318
      IF(IPTAQ.EQ.0)GO TO 317
      IF(ITAG(I).NE.IPTAQ)GO TO 316
317   ITMP1=ITMP1+1
      IF(ITMP1.LT.IPTAQF.OR.ITMP1.GT.IPTAQT)GO TO 316
318   CURI=FR*DCMPLX(-BII(I),BIR(I))
      CMAG=ABS(CURI)
      PH=CANG(CURI)
      WRITE(3,165) I,ITAG(I),X(I),Y(I),Z(I),SI(I),CURI,CMAG,PH
316   CONTINUE
308   IF(M.EQ.0)GO TO 310
      WRITE(3,197)
      J=N-2
      ITMP1=LD+1
      DO 309 I=1,M
      J=J+3
      ITMP1=ITMP1-1
      EX=CUR(J)
      EY=CUR(J+1)
      EZ=CUR(J+2)
      ETH=EX*T1X(ITMP1)+EY*T1Y(ITMP1)+EZ*T1Z(ITMP1)
      EPH=EX*T2X(ITMP1)+EY*T2Y(ITMP1)+EZ*T2Z(ITMP1)
      ETHM=ABS(ETH)
      ETHA=CANG(ETH)
      EPHM=ABS(EPH)
      EPHA=CANG(EPH)
!309   WRITE(3,198) I,X(ITMP1),Y(ITMP1),Z(ITMP1),ETHM,ETHA,EPHM,EPHA,E
!     1X,EY, EZ
!***
      WRITE(3,198) I,X(ITMP1),Y(ITMP1),Z(ITMP1),ETHM,ETHA,EPHM,EPHA,E
     1X,EY,EZ
      IF(IPLP1 .NE. 1) GO TO 309
      IF(IPLP3 .EQ. 1) WRITE(8,*) EX
      IF(IPLP3 .EQ. 2) WRITE(8,*) EY
      IF(IPLP3 .EQ. 3) WRITE(8,*) EZ
      IF(IPLP3 .EQ. 4) WRITE(8,*) EX,EY,EZ
309   CONTINUE
!***
310   IF (IXTYP.NE.0.AND.IXTYP.NE.5) GO TO 70
      TMP1=PIN-PNLS-PLOSS
      TMP2=100.*TMP1/PIN
      WRITE(3,166)  PIN,TMP1,PLOSS,PNLS,TMP2
70    CONTINUE
      IGO=4
      IF(NCOUP.GT.0)CALL COUPLE(CUR,WLAM)
      IF (IFLOW.NE.7) GO TO 71
      IF (IXTYP.GT.0.AND.IXTYP.LT.4) GO TO 113
      IF (NFRQ.NE.1) GO TO 120
      WRITE(3,135)
      GO TO 14
71    IGO=5
!
!     NEAR FIELD CALCULATION
!
72    IF (NEAR.EQ.(-1)) GO TO 78
      CALL NFPAT
      IF (MHZ.EQ.NFRQ) NEAR=-1
      IF (NFRQ.NE.1) GO TO 78
      WRITE(3,135)
      GO TO 14
!
!     STANDARD FAR FIELD CALCULATION
!
78    IF(IFAR.EQ.-1)GO TO 113
      PINR=PIN
      PNLR=PNLS
      CALL RDPAT
113   IF (IXTYP.EQ.0.OR.IXTYP.GE.4) GO TO 119
      NTHIC=NTHIC+1
      INC=INC+1
      XPR1=XPR1+XPR4
      IF (NTHIC.LE.NTHI) GO TO 54
      NTHIC=1
      XPR1=THETIS
      XPR2=XPR2+XPR5
      NPHIC=NPHIC+1
      IF (NPHIC.LE.NPHI) GO TO 54
      NPHIC=1
      XPR2=PHISS
      IF (IPTFLG.LT.2) GO TO 119
!     NORMALIZED RECEIVING PATTERN PRINTED
      ITMP1=NTHI*NPHI
      IF (ITMP1.LE.NORMF) GO TO 114
      ITMP1=NORMF
      WRITE(3,181)
114   TMP1=FNORM(1)
      DO 115 J=2,ITMP1
      IF (FNORM(J).GT.TMP1) TMP1=FNORM(J)
115   CONTINUE
      WRITE(3,182)  TMP1,XPR3,HPOL(IXTYP),XPR6,ISAVE
      DO 118 J=1,NPHI
      ITMP2=NTHI*(J-1)
      DO 116 I=1,NTHI
      ITMP3=I+ITMP2
      IF (ITMP3.GT.ITMP1) GO TO 117
      TMP2=FNORM(ITMP3)/TMP1
      TMP3=DB20(TMP2)
      WRITE(3,183)  XPR1,XPR2,TMP3,TMP2
      XPR1=XPR1+XPR4
116   CONTINUE
117   XPR1=THETIS
      XPR2=XPR2+XPR5
118   CONTINUE
      XPR2=PHISS
119   IF (MHZ.EQ.NFRQ) IFAR=-1
      IF (NFRQ.NE.1) GO TO 120
      WRITE(3,135)
      GO TO 14
120   MHZ=MHZ+1
      IF (MHZ.LE.NFRQ) GO TO 42
      IF (IPED.EQ.0) GO TO 123
      IF(NVQD.LT.1)GO TO 199
      WRITE(3,184) IVQD(NVQD),ZPNORM
      GO TO 204
199   WRITE(3,184)  ISANT(NSANT),ZPNORM
204   ITMP1=NFRQ
      IF (ITMP1.LE.(NORMF/4)) GO TO 121
      ITMP1=NORMF/4
      WRITE(3,185)
121   IF (IFRQ.EQ.0) TMP1=FMHZ-(NFRQ-1)*DELFRQ
      IF (IFRQ.EQ.1) TMP1=FMHZ/(DELFRQ**(NFRQ-1))
      DO 122 I=1,ITMP1
      ITMP2=I+4*(I-1)
      TMP2=FNORM(ITMP2)/ZPNORM
      TMP3=FNORM(ITMP2+1)/ZPNORM
      TMP4=FNORM(ITMP2+2)/ZPNORM
      TMP5=FNORM(ITMP2+3)
      WRITE(3,186)  TMP1,FNORM(ITMP2),FNORM(ITMP2+1),FNORM(ITMP2+2),
     1FNORM(ITMP2+3),TMP2,TMP3,TMP4,TMP5
      IF (IFRQ.EQ.0) TMP1=TMP1+DELFRQ
      IF (IFRQ.EQ.1) TMP1=TMP1*DELFRQ
122   CONTINUE
      WRITE(3,135)
123   CONTINUE
      NFRQ=1
      MHZ=1
      GO TO 14
125   FORMAT (A2,19A4)
126   FORMAT  ('1')
127   FORMAT (///,33X,'*********************************************',
     &//,36X,'NUMERICAL ELECTROMAGNETICS CODE (NEC-2D)',//,33X,
     2 '*********************************************')
128   FORMAT (////,37X,'- - - - COMMENTS - - - -',//)
129   FORMAT (25X,20A4)
130   FORMAT (///,10X,'INCORRECT LABEL FOR A COMMENT CARD')
135   FORMAT (/////)
136   FORMAT (A2,I3,3I5,6E10.3)
137   FORMAT (1X,'***** DATA CARD NO.',I3,3X,A2,1X,I3,3(1X,I5),
     1 6(1X,1P,E12.5))
138   FORMAT (///,10X,'FAULTY DATA CARD LABEL AFTER GEOMETRY SECTION')
139   FORMAT (///,10X,'NUMBER OF LOADING CARDS EXCEEDS STORAGE ALLOTTED'
     1)
140   FORMAT (///,10X,'DATA FAULT ON LOADING CARD NO.=',I5,5X,
     &'ITAG STEP1=',I5,'  IS GREATER THAN ITAG STEP2=',I5)
141   FORMAT (///,10X,'NUMBER OF EXCITATION CARDS EXCEEDS STORAGE ALLO',
     &'TTED')
142   FORMAT (///,10X,'NUMBER OF NETWORK CARDS EXCEEDS STORAGE ALLOTTE',
     &'D')
143   FORMAT(///,10X,'WHEN MULTIPLE FREQUENCIES ARE REQUESTED, ONLY ON',
     &'E NEAR FIELD CARD CAN BE USED -',/,10X,'LAST CARD READ IS USED')
145   FORMAT (////,33X,'- - - - - - FREQUENCY - - - - - -',//,36X,
     &'FREQUENCY=',1P,E11.4,' MHZ',/,36X,'WAVELENGTH=',E11.4,' METERS')
146   FORMAT (///,30X,' - - - STRUCTURE IMPEDANCE LOADING - - -')
147   FORMAT (/ ,35X,'THIS STRUCTURE IS NOT LOADED')
148   FORMAT (///,34X,'- - - ANTENNA ENVIRONMENT - - -',/)
149   FORMAT (40X,'MEDIUM UNDER SCREEN -')
150   FORMAT (40X,'RELATIVE DIELECTRIC CONST.=',F7.3,/,40X,'CONDUCTIV',
     &'ITY=',1P,E10.3,' MHOS/METER',/,40X,'COMPLEX DIELECTRIC CONSTANT='
     &,2E12.5)
151   FORMAT (  42X,'PERFECT GROUND')
152   FORMAT (  44X,'FREE SPACE')
153   FORMAT (///,32X,'- - - MATRIX TIMING - - -',//,24X,'FILL=',F9.3,
     1' SEC.,  FACTOR=',F9.3,' SEC.')
154   FORMAT (///,40X,'- - - EXCITATION - - -')
155   FORMAT (/,4X,'PLANE WAVE',4X,'THETA=',F7.2,' DEG,  PHI=',F7.2,
     &' DEG,  ETA=',F7.2,' DEG,  TYPE -',A6,'=  AXIAL RATIO=',F6.3)
156   FORMAT (/,31X,'POSITION (METERS)',14X,'ORIENTATION (DEG)=',/,28X,
     1'X',12X,'Y',12X,'Z',10X,'ALPHA',5X,'BETA',4X,'DIPOLE MOMENT',//
     2 ,4X,'CURRENT SOURCE',1X,3(3X,F10.5),1X,2(3X,F7.2),4X,F8.3)
157   FORMAT (4X,4(I5,1X),1P,6(3X,E11.4),3X,A6,A2)
158   FORMAT (///,44X,'- - - NETWORK DATA - - -')
159   FORMAT (/,6X,'- FROM -    - TO -',11X,'TRANSMISSION LINE',15X,
     &'-  -  SHUNT ADMITTANCES (MHOS)  -  -',14X,'LINE',/,6X,'TAG  SEG.'
     2,'   TAG  SEG.',6X,'IMPEDANCE',6X,'LENGTH',12X,'- END ONE -',17X,
     3'- END TWO -',12X,'TYPE',/,6X,'NO.   NO.   NO.   NO.',9X,'OHMS',
     &8X,'METERS',9X,'REAL',10X,'IMAG.',9X,'REAL',10X,'IMAG.')
160   FORMAT (/,6X,'- FROM -',4X,'- TO -',26X,'-  -  ADMITTANCE MATRIX',
     1' ELEMENTS (MHOS)  -  -',/,6X,'TAG  SEG.   TAG  SEG.',13X,'(ON',
     2'E,ONE)',19X,'(ONE,TWO)',19X,'(TWO,TWO)',/ ,6X,'NO.   NO.   NO',
     3'.   NO.',8X,'REAL',10X,'IMAG.',9X,'REAL',10X,'IMAG.',9X,'REAL',
     4 10X,'IMAG.')
161   FORMAT (///,29X,'- - - CURRENTS AND LOCATION - - -',//,33X,
     &'DISTANCES IN WAVELENGTHS')
162   FORMAT (  //,2X,'SEG.',2X,'TAG',4X,'COORD. OF SEG. CENTER',5X,
     1 'SEG.',12X,'- - - CURRENT (AMPS) - - -',/,2X,'NO.',3X,'NO.',
     2 5X,'X',8X,'Y',8X,'Z',6X,'LENGTH',5X,'REAL',8X,'IMAG.',7X,'MAG.',
     3 8X,'PHASE')
163   FORMAT (///,33X,'- - - RECEIVING PATTERN PARAMETERS - - -',/,43X,
     &'ETA=',F7.2,' DEGREES',/,43X,'TYPE -',A6,/,43X,'AXIAL RATIO=',
     & F6.3,//,11X,'THETA',6X,'PHI',10X,'-  CURRENT  -',9X,'SEG',/,
     &11X,'(DEG)',5X,'(DEG)',7X,'MAGNITUDE',4X,'PHASE',6X,'NO.',/)
164   FORMAT (10X,2(F7.2,3X),1X,1P,E11.4,3X,0P,F7.2,4X,I5)
165   FORMAT (1X,2I5,3F9.4,F9.5,1X,1P,3E12.4,0P,F9.3)
166   FORMAT (///,40X,'- - - POWER BUDGET - - -',//,43X,'INPUT POWER   =
     &',1P,E11.4,' WATTS',/ ,43X,'RADIATED POWER=',E11.4,' WATTS',
     &/,43X,'STRUCTURE LOSS=',E11.4,' WATTS',/,43X,'NETWORK LOSS  =',
     &E11.4,' WATTS',/,43X,'EFFICIENCY    =',0P,F7.2,' PERCENT')
170   FORMAT (40X,'RADIAL WIRE GROUND SCREEN',/,40X,I5,' WIRES',/,40X,
     1'WIRE LENGTH=',F8.2,' METERS',/,40X,'WIRE RADIUS=',1P,E10.3,
     2' METERS')
181   FORMAT (///,4X,'RECEIVING PATTERN STORAGE TOO SMALL,ARRAY TRUNCA',
     1'TED')
182   FORMAT (///,32X,'- - - NORMALIZED RECEIVING PATTERN - - -',/,41X,
     1'NORMALIZATION FACTOR=',1P,E11.4,/,41X,'ETA=',0P,F7.2,' DEGREES',
     2/,41X,'TYPE -',A6,/,41X,'AXIAL RATIO=',F6.3,/,41X,'SEGMENT NO.=',
     3I5,//,21X,'THETA',6X,'PHI',9X,'-  PATTERN  -',/,21X,'(DEG)',5X,
     4'(DEG)',8X,'DB',8X,'MAGNITUDE',/)
183   FORMAT (20X,2(F7.2,3X),1X,F7.2,4X,1P,E11.4)
184   FORMAT (///,36X,32H- - - INPUT IMPEDANCE DATA - - -,/   ,45X,18HSO
     1URCE SEGMENT NO.,I4,/  ,45X,21HNORMALIZATION FACTOR=,1P,E12.5,//
     2,7X,5HFREQ.,13X,34H-  -  UNNORMALIZED IMPEDANCE  -  -,21X,   32H- 
     3 -  NORMALIZED IMPEDANCE  -  -,/    ,19X,10HRESISTANCE,4X,9HREACTA
     4NCE,6X,9HMAGNITUDE,4X,5HPHASE,7X,10HRESISTANCE,4X,9HREACTANCE,6X,
     5 9HMAGNITUDE,4X,5HPHASE,/    ,8X,3HMHZ,11X,4HOHMS,10X,4HOHMS,11X,
     6 4HOHMS,5X,7HDEGREES,47X,7HDEGREES,/)
185   FORMAT (///,4X,62HSTORAGE FOR IMPEDANCE NORMALIZATION TOO SMALL, A
     1RRAY TRUNCATED)
186   FORMAT (3X,F9.3,2X,1P,2(2X,E12.5),3X,E12.5,2X,0P,F7.2,2X,1P,2(2X,
     1 E12.5),3X,E12.5,2X,0P,F7.2)
196   FORMAT(   ////,20X,55HAPPROXIMATE INTEGRATION EMPLOYED FOR SEGMENT
     1S MORE THAN,F8.3,18H WAVELENGTHS APART)
197   FORMAT(   ////,41X,38H- - - - SURFACE PATCH CURRENTS - - - -,//,
     1 50X,23HDISTANCE IN WAVELENGTHS,/,50X,21HCURRENT IN AMPS/METER,
     1 //,28X,26H- - SURFACE COMPONENTS - -,19X,34H- - - RECTANGULAR COM
     1PONENTS - - -,/,6X,12HPATCH CENTER,6X,16HTANGENT VECTOR 1,3X,
     116HTANGENT VECTOR 2,11X,1HX,19X,1HY,19X,1HZ,/,5X,1HX,6X,1HY,6X,
     11HZ,5X,4HMAG.,7X,5HPHASE,3X,4HMAG.,7X,5HPHASE,3(4X,4HREAL,6X,
     1 6HIMAG. ))
198   FORMAT(1X,I4,/,1X,3F7.3,2(1P,E11.4,0P,F8.2),1P,6E10.2)
201   FORMAT(/,11H RUN TIME =,F10.3)
315   FORMAT(///,34X,28H- - - CHARGE DENSITIES - - -,//,36X,
     1 24HDISTANCES IN WAVELENGTHS,///,2X,4HSEG.,2X,3HTAG,4X,
     2 21HCOORD. OF SEG. CENTER,5X,4HSEG.,10X,
     3 31HCHARGE DENSITY (COULOMBS/METER),/,2X,3HNO.,3X,3HNO.,5X,1HX,8X,
     4 1HY,8X,1HZ,6X,6HLENGTH,5X,4HREAL,8X,5HIMAG.,7X,4HMAG.,8X,5HPHASE)
321   FORMAT( /,20X,42HTHE EXTENDED THIN WIRE KERNEL WILL BE USED)
303   FORMAT(/,9H ERROR - ,A2,32H CARD IS NOT ALLOWED WITH N.G.F.)
327   FORMAT(/,35X,31H LOADING ONLY IN N.G.F. SECTION)
302   FORMAT(48H ERROR - N.G.F. IN USE.  CANNOT WRITE NEW N.G.F.)
313   FORMAT(/,62H NUMBER OF SEGMENTS IN COUPLING CALCULATION (CP) EXCEE
     1DS LIMIT)
390   FORMAT(78H RADIAL WIRE G. S. APPROXIMATION MAY NOT BE USED WITH SO
     1MMERFELD GROUND OPTION)
391   FORMAT(40X,52HFINITE GROUND.  REFLECTION COEFFICIENT APPROXIMATION
     1)
392   FORMAT(40X,35HFINITE GROUND.  SOMMERFELD SOLUTION)
393   FORMAT(/,29H ERROR IN GROUND PARAMETERS -,/,41H COMPLEX DIELECTRIC
     1 CONSTANT FROM FILE IS,1P,2E12.5,/,32X,9HREQUESTED,2E12.5)
900   FORMAT(' ERROR OPENING SOMMERFELD GROUND FILE - SOM2D.NEC')
      END

! ################## START OF SOM2D INCLUDE ########################

!***********************************************************************
!----------------------------------------------------------------------------

      SUBROUTINE SOM2D (rmhz, repr, rsig)
!***********************************************************************

      IMPLICIT REAL*8(A-H,O-Z)
!***
      COMPLEX*16 CK1,CK1SQ,ERV,EZV,ERH,EPH,CKSM,CT1,CT2,CT3,CL1,CL2,CON,
     -AR1,AR2,AR3,EPSCF
      COMMON /EVLCOM/ CKSM,CT1,CT2,CT3,CK1,CK1SQ,CK2,CK2SQ,TKMAG,TSMAG,C
     -K1R,ZPH,RHO,JH
      COMMON /GGRID/ AR1(11,10,4),AR2(17,5,4),AR3(9,8,4),EPSCF,DXA(3),DY
     -A(3),XSA(3),YSA(3),NXA(3),NYA(3)

      CHARACTER*3  LCOMP(4)
      DATA LCOMP/'ERV','EZV','ERH','EPH'/
!
	epr = repr		! av03
	sig = rsig		! av03
	fmhz = rmhz		! av03
	ipt=0			! No printing, av03

!deb	write (*,100) fmhz,epr,sig
!deb  100 format (' Som2d: Freq=',d10.5,' Diel=',d10.5,' Cond=',d10.5)

!***
      IF (SIG.LT.0.) GO TO 1
      WLAM=299.8/FMHZ
      EPSCF=DCMPLX(EPR,-SIG*WLAM*59.96)
      GO TO 2
1     EPSCF=DCMPLX(EPR,SIG)
2     CONTINUE
      CK2=6.283185308
      CK2SQ=CK2*CK2
!
!     SOMMERFELD INTEGRAL EVALUATION USES EXP(-JWT), NEC USES EXP(+JWT),
!     HENCE NEED CONJG(EPSCF).  CONJUGATE OF FIELDS OCCURS IN SUBROUTINE
!     EVLUA.
!
      CK1SQ=CK2SQ*DCONJG(EPSCF)
      CK1=SQRT(CK1SQ)
      CK1R=DREAL(CK1)
      TKMAG=100.*ABS(CK1)
      TSMAG=100.*CK1*DCONJG(CK1)
      CKSM=CK2SQ/(CK1SQ+CK2SQ)
      CT1=.5*(CK1SQ-CK2SQ)
      ERV=CK1SQ*CK1SQ
      EZV=CK2SQ*CK2SQ
      CT2=.125*(ERV-EZV)
      ERV=ERV*CK1SQ
      EZV=EZV*CK2SQ
      CT3=.0625*(ERV-EZV)
!
!     LOOP OVER 3 GRID REGIONS
!
      DO 6 K=1,3
      NR=NXA(K)
      NTH=NYA(K)
      DR=DXA(K)
      DTH=DYA(K)
      R=XSA(K)-DR
      IRS=1
      IF (K.EQ.1) R=XSA(K)
      IF (K.EQ.1) IRS=2
!
!     LOOP OVER R.  (R=SQRT(RHO**2 + (Z+H)**2))
!
      DO 6 IR=IRS,NR
      R=R+DR
      THET=YSA(K)-DTH
!
!     LOOP OVER THETA.  (THETA=ATAN((Z+H)/RHO))
!
      DO 6 ITH=1,NTH
      THET=THET+DTH
      RHO=R*COS(THET)
      ZPH=R*SIN(THET)
      IF (RHO.LT.1.E-7) RHO=1.E-8
      IF (ZPH.LT.1.E-7) ZPH=0.
      CALL EVLUA (ERV,EZV,ERH,EPH)
      RK=CK2*R
      CON=-(0.,4.77147)*R/DCMPLX(COS(RK),-SIN(RK))
      GO TO (3,4,5), K
3     AR1(IR,ITH,1)=ERV*CON
      AR1(IR,ITH,2)=EZV*CON
      AR1(IR,ITH,3)=ERH*CON
      AR1(IR,ITH,4)=EPH*CON
      GO TO 6
4     AR2(IR,ITH,1)=ERV*CON
      AR2(IR,ITH,2)=EZV*CON
      AR2(IR,ITH,3)=ERH*CON
      AR2(IR,ITH,4)=EPH*CON
      GO TO 6
5     AR3(IR,ITH,1)=ERV*CON
      AR3(IR,ITH,2)=EZV*CON
      AR3(IR,ITH,3)=ERH*CON
      AR3(IR,ITH,4)=EPH*CON
6     CONTINUE
!
!     FILL GRID 1 FOR R EQUAL TO ZERO.
!
      CL2=-(0.,188.370)*(EPSCF-1.)/(EPSCF+1.)
      CL1=CL2/(EPSCF+1.)
      EZV=EPSCF*CL1
      THET=-DTH
      NTH=NYA(1)
      DO 9 ITH=1,NTH
      THET=THET+DTH
      IF (ITH.EQ.NTH) GO TO 7
      TFAC2=COS(THET)
      TFAC1=(1.-SIN(THET))/TFAC2
      TFAC2=TFAC1/TFAC2
      ERV=EPSCF*CL1*TFAC1
      ERH=CL1*(TFAC2-1.)+CL2
      EPH=CL1*TFAC2-CL2
      GO TO 8
7     ERV=0.
      ERH=CL2-.5*CL1
      EPH=-ERH
8     AR1(1,ITH,1)=ERV
      AR1(1,ITH,2)=EZV
      AR1(1,ITH,3)=ERH
9     AR1(1,ITH,4)=EPH
!
!     WRITE GRID ON TAPE21
!
      IF (IPT.EQ.0) RETURN						! av03
!
!     PRINT GRID
!
      OPEN (UNIT=9,FILE='SOM2D.OUT',STATUS='UNKNOWN',ERR=14)! av04
      WRITE(3,17) EPSCF
      DO 13 K=1,3
      NR=NXA(K)
      NTH=NYA(K)
      WRITE(9,18) K,XSA(K),DXA(K),NR,YSA(K),DYA(K),NTH
      DO 13 L=1,4
      WRITE(9,19) LCOMP(L)
      DO 13 IR=1,NR
      GO TO (10,11,12), K
10    WRITE(9,20) IR,(AR1(IR,ITH,L),ITH=1,NTH)
      GO TO 13
11    WRITE(9,20) IR,(AR2(IR,ITH,L),ITH=1,NTH)
      GO TO 13
12    WRITE(9,20) IR,(AR3(IR,ITH,L),ITH=1,NTH)
13    CONTINUE
14    return								! av03
!
16    FORMAT (6H TIME=,1PE12.5)
17    FORMAT (30H1NEC GROUND INTERPOLATION GRID,/,21H DIELECTRIC CONSTAN
     1T=,1P2E12.5)
18    FORMAT (///,5H GRID,I2,/,4X,5HR(1)=,F7.4,4X,3HDR=,F7.4,4X,3HNR=,I3
     1,/,9H THET(1)=,F7.4,3X,4HDTH=,F7.4,3X,4HNTH=,I3,//)
19    FORMAT (///,1X,A3)
20    FORMAT (4H IR=,I3,/,1X,(1P10E12.5))
22    FORMAT(' STARTING COMPUTATION OF SOMMERFELD INTEGRAL TABLES')
      END

!***********************************************************************
      BLOCK DATA SOMSET
!***********************************************************************

      IMPLICIT REAL*8(A-H,O-Z)
      COMPLEX*16 AR1,AR2,AR3,EPSCF
      COMMON /GGRID/ AR1(11,10,4),AR2(17,5,4),AR3(9,8,4),EPSCF,DXA(3),DY
     1A(3),XSA(3),YSA(3),NXA(3),NYA(3)
      DATA NXA/11,17,9/,NYA/10,5,8/,XSA/0.,.2,.2/,YSA/0.,0.,.3490658504/
      DATA DXA/.02,.05,.1/,DYA/.1745329252,.0872664626,.1745329252/

      END

!***********************************************************************
!----------------------------------------------------------------------------

      SUBROUTINE BESSEL (Z,J0,J0P)
!***********************************************************************
!
!     BESSEL EVALUATES THE ZERO-ORDER BESSEL FUNCTION AND ITS DERIVATIVE
!     FOR COMPLEX ARGUMENT Z.
!
      IMPLICIT REAL*8(A-H,O-Z)
      SAVE
      COMPLEX*16 J0,J0P,P0Z,P1Z,Q0Z,Q1Z,Z,ZI,ZI2,ZK,FJ,CZ,SZ,J0X,J0PX
      DIMENSION M(101), A1(25), A2(25), FJX(2)
      EQUIVALENCE (FJ,FJX)

      DATA C3,P10,P20,Q10,Q20/.7978845608,.0703125,.11215
     -20996,.125,.0732421875/

      DATA P11,P21,Q11,Q21/.1171875,.1441955566,.375,.1025390625/
      DATA POF,INIT/.7853981635,0/,FJX/0.,1./

      IF (INIT.EQ.0) GO TO 5
1     ZMS=Z*DCONJG(Z)
      IF (ZMS.GT.1.E-12) GO TO 2
      J0=(1.,0.)
      J0P=-.5*Z
      RETURN

2     IB=0
      IF (ZMS.GT.37.21) GO TO 4
      IF (ZMS.GT.36.) IB=1
!     SERIES EXPANSION
      IZ=1.+ZMS
      MIZ=M(IZ)
      J0=(1.,0.)
      J0P=J0
      ZK=J0
      ZI=Z*Z
      DO 3 K=1,MIZ
      ZK=ZK*A1(K)*ZI
      J0=J0+ZK
3     J0P=J0P+A2(K)*ZK
      J0P=-.5*Z*J0P
      IF (IB.EQ.0) RETURN
      J0X=J0
      J0PX=J0P
!     ASYMPTOTIC EXPANSION
4     ZI=1./Z
      ZI2=ZI*ZI
      P0Z=1.+(P20*ZI2-P10)*ZI2
      P1Z=1.+(P11-P21*ZI2)*ZI2
      Q0Z=(Q20*ZI2-Q10)*ZI
      Q1Z=(Q11-Q21*ZI2)*ZI
      ZK=EXP(FJ*(Z-POF))
      ZI2=1./ZK
      CZ=.5*(ZK+ZI2)
      SZ=FJ*.5*(ZI2-ZK)
      ZK=C3*SQRT(ZI)
      J0=ZK*(P0Z*CZ-Q0Z*SZ)
      J0P=-ZK*(P1Z*SZ+Q1Z*CZ)
      IF (IB.EQ.0) RETURN
      ZMS=COS((SQRT(ZMS)-6.)*31.41592654)
      J0=.5*(J0X*(1.+ZMS)+J0*(1.-ZMS))
      J0P=.5*(J0PX*(1.+ZMS)+J0P*(1.-ZMS))
      RETURN

!     INITIALIZATION OF CONSTANTS
5     DO 6 K=1,25
      A1(K)=-.25D0/(K*K)
6     A2(K)=1.D0/(K+1.D0)
      DO 8 I=1,101
      TEST=1.D0
      DO 7 K=1,24
      INIT=K
      TEST=-TEST*I*A1(K)
      IF (TEST.LT.1.D-6) GO TO 8
7     CONTINUE
8     M(I)=INIT
      GO TO 1
      END

!***********************************************************************
!----------------------------------------------------------------------------

      SUBROUTINE EVLUA (ERV,EZV,ERH,EPH)
!***********************************************************************
!
!     EVALUA CONTROLS THE INTEGRATION CONTOUR IN THE COMPLEX LAMBDA
!     PLANE FOR EVALUATION OF THE SOMMERFELD INTEGRALS.
!
      IMPLICIT REAL*8(A-H,O-Z)
      SAVE
      COMPLEX*16 ERV,EZV,ERH,EPH,A,B,CK1,CK1SQ,BK,SUM,DELTA,ANS,DELTA2,
     1CP1,CP2,CP3,CKSM,CT1,CT2,CT3
      COMMON /CNTOUR/ A,B
      COMMON /EVLCOM/ CKSM,CT1,CT2,CT3,CK1,CK1SQ,CK2,CK2SQ,TKMAG,TSMAG,C
     1K1R,ZPH,RHO,JH
      DIMENSION SUM(6), ANS(6)
      DATA PTP/.6283185308/
      DEL=ZPH
      IF (RHO.GT.DEL) DEL=RHO
      IF (ZPH.LT.2.*RHO) GO TO 4
!
!     BESSEL FUNCTION FORM OF SOMMERFELD INTEGRALS
!
      JH=0
      A=(0.,0.)
      DEL=1./DEL
      IF (DEL.LE.TKMAG) GO TO 2
      B=DCMPLX(.1*TKMAG,-.1*TKMAG)
      CALL ROM1 (6,SUM,2)
      A=B
      B=DCMPLX(DEL,-DEL)
      CALL ROM1 (6,ANS,2)
      DO 1 I=1,6
1     SUM(I)=SUM(I)+ANS(I)
      GO TO 3
2     B=DCMPLX(DEL,-DEL)
      CALL ROM1 (6,SUM,2)
3     DELTA=PTP*DEL
      CALL GSHANK (B,DELTA,ANS,6,SUM,0,B,B)
      GO TO 10
!
!     HANKEL FUNCTION FORM OF SOMMERFELD INTEGRALS
!
4     JH=1
      CP1=DCMPLX(0.D0,.4*CK2)
      CP2=DCMPLX(.6*CK2,-.2*CK2)
      CP3=DCMPLX(1.02*CK2,-.2*CK2)
      A=CP1
      B=CP2
      CALL ROM1 (6,SUM,2)
      A=CP2
      B=CP3
      CALL ROM1 (6,ANS,2)
      DO 5 I=1,6
5     SUM(I)=-(SUM(I)+ANS(I))
!     PATH FROM IMAGINARY AXIS TO -INFINITY
      SLOPE=1000.
      IF (ZPH.GT..001*RHO) SLOPE=RHO/ZPH
      DEL=PTP/DEL
      DELTA=DCMPLX(-1.D0,SLOPE)*DEL/SQRT(1.+SLOPE*SLOPE)
      DELTA2=-DCONJG(DELTA)
      CALL GSHANK (CP1,DELTA,ANS,6,SUM,0,BK,BK)
      RMIS=RHO*(DREAL(CK1)-CK2)
      IF (RMIS.LT.2.*CK2) GO TO 8
      IF (RHO.LT.1.E-10) GO TO 8
      IF (ZPH.LT.1.E-10) GO TO 6
      BK=DCMPLX(-ZPH,RHO)*(CK1-CP3)
      RMIS=-DREAL(BK)/ABS(DIMAG(BK))
      IF(RMIS.GT.4.*RHO/ZPH)GO TO 8
!     INTEGRATE UP BETWEEN BRANCH CUTS, THEN TO + INFINITY
6     CP1=CK1-(.1,.2)
      CP2=CP1+.2
      BK=DCMPLX(0.D0,DEL)
      CALL GSHANK (CP1,BK,SUM,6,ANS,0,BK,BK)
      A=CP1
      B=CP2
      CALL ROM1 (6,ANS,1)
      DO 7 I=1,6
7     ANS(I)=ANS(I)-SUM(I)
      CALL GSHANK (CP3,BK,SUM,6,ANS,0,BK,BK)
      CALL GSHANK (CP2,DELTA2,ANS,6,SUM,0,BK,BK)
      GO TO 10
!     INTEGRATE BELOW BRANCH POINTS, THEN TO + INFINITY
8     DO 9 I=1,6
9     SUM(I)=-ANS(I)
      RMIS=DREAL(CK1)*1.01
      IF (CK2+1..GT.RMIS) RMIS=CK2+1.
      BK=DCMPLX(RMIS,.99*DIMAG(CK1))
      DELTA=BK-CP3
      DELTA=DELTA*DEL/ABS(DELTA)
      CALL GSHANK (CP3,DELTA,ANS,6,SUM,1,BK,DELTA2)
10    ANS(6)=ANS(6)*CK1
!     CONJUGATE SINCE NEC USES EXP(+JWT)
      ERV=DCONJG(CK1SQ*ANS(3))
      EZV=DCONJG(CK1SQ*(ANS(2)+CK2SQ*ANS(5)))
      ERH=DCONJG(CK2SQ*(ANS(1)+ANS(6)))
      EPH=-DCONJG(CK2SQ*(ANS(4)+ANS(6)))
      RETURN
      END

!***********************************************************************
!----------------------------------------------------------------------------

      SUBROUTINE GSHANK (START,DELA,SUM,NANS,SEED,IBK,BK,DELB)
!***********************************************************************
!
!     GSHANK INTEGRATES THE 6 SOMMERFELD INTEGRALS FROM START TO
!     INFINITY (UNTIL CONVERGENCE) IN LAMBDA.  AT THE BREAK POINT, BK,
!     THE STEP INCREMENT MAY BE CHANGED FROM DELA TO DELB.  SHANK S
!     ALGORITHM TO ACCELERATE CONVERGENCE OF A SLOWLY CONVERGING SERIES
!     IS USED
!
      IMPLICIT REAL*8(A-H,O-Z)
      SAVE
      COMPLEX*16 START,DELA,SUM,SEED,BK,DELB,A,B,Q1,Q2,ANS1,ANS2,A1,A2,
     1AS1,AS2,DEL,AA
      COMMON /CNTOUR/ A,B
      DIMENSION Q1(6,20), Q2(6,20), ANS1(6), ANS2(6), SUM(6), SEED(6)
      DATA CRIT/1.E-4/,MAXH/20/
      RBK=DREAL(BK)
      DEL=DELA
      IBX=0
      IF (IBK.EQ.0) IBX=1
      DO 1 I=1,NANS
1     ANS2(I)=SEED(I)
      B=START
2     DO 20 INT=1,MAXH
      INX=INT
      A=B
      B=B+DEL
      IF (IBX.EQ.0.AND.DREAL(B).GE.RBK) GO TO 5
      CALL ROM1 (NANS,SUM,2)
      DO 3 I=1,NANS
3     ANS1(I)=ANS2(I)+SUM(I)
      A=B
      B=B+DEL
      IF (IBX.EQ.0.AND.DREAL(B).GE.RBK) GO TO 6
      CALL ROM1 (NANS,SUM,2)
      DO 4 I=1,NANS
4     ANS2(I)=ANS1(I)+SUM(I)
      GO TO 11
!     HIT BREAK POINT.  RESET SEED AND START OVER.
5     IBX=1
      GO TO 7
6     IBX=2
7     B=BK
      DEL=DELB
      CALL ROM1 (NANS,SUM,2)
      IF (IBX.EQ.2) GO TO 9
      DO 8 I=1,NANS
8     ANS2(I)=ANS2(I)+SUM(I)
      GO TO 2
9     DO 10 I=1,NANS
10    ANS2(I)=ANS1(I)+SUM(I)
      GO TO 2
11    DEN=0.
      DO 18 I=1,NANS
      AS1=ANS1(I)
      AS2=ANS2(I)
      IF (INT.LT.2) GO TO 17
      DO 16 J=2,INT
      JM=J-1
      AA=Q2(I,JM)
      A1=Q1(I,JM)+AS1-2.*AA
      IF (DREAL(A1).EQ.0..AND.DIMAG(A1).EQ.0.) GO TO 12
      A2=AA-Q1(I,JM)
      A1=Q1(I,JM)-A2*A2/A1
      GO TO 13
12    A1=Q1(I,JM)
13    A2=AA+AS2-2.*AS1
      IF (DREAL(A2).EQ.0..AND.DIMAG(A2).EQ.0.) GO TO 14
      A2=AA-(AS1-AA)*(AS1-AA)/A2
      GO TO 15
14    A2=AA
15    Q1(I,JM)=AS1
      Q2(I,JM)=AS2
      AS1=A1
16    AS2=A2
17    Q1(I,INT)=AS1
      Q2(I,INT)=AS2
      AMG=ABS(DREAL(AS2))+ABS(DIMAG(AS2))
      IF (AMG.GT.DEN) DEN=AMG
18    CONTINUE
      DENM=1.E-3*DEN*CRIT
      JM=INT-3
      IF (JM.LT.1) JM=1
      DO 19 J=JM,INT
      DO 19 I=1,NANS
      A1=Q2(I,J)
      DEN=(ABS(DREAL(A1))+ABS(DIMAG(A1)))*CRIT
      IF (DEN.LT.DENM) DEN=DENM
      A1=Q1(I,J)-A1
      AMG=ABS(DREAL(A1))+ABS(DIMAG(A1))
      IF (AMG.GT.DEN) GO TO 20
19    CONTINUE
      GO TO 22
20    CONTINUE
      WRITE(*,24)
      DO 21 I=1,NANS
21    WRITE(*,25) Q1(I,INX),Q2(I,INX)
22    DO 23 I=1,NANS
23    SUM(I)=.5*(Q1(I,INX)+Q2(I,INX))
      RETURN
!
24    FORMAT (46H **** NO CONVERGENCE IN SUBROUTINE GSHANK ****)
25    FORMAT (1X,1P10E12.5)
      END

!***********************************************************************
!----------------------------------------------------------------------------

      SUBROUTINE HANKEL (Z,H0,H0P)
!***********************************************************************
!
!     HANKEL EVALUATES HANKEL FUNCTION OF THE FIRST KIND, ORDER ZERO,
!     AND ITS DERIVATIVE FOR COMPLEX ARGUMENT Z.
!
      IMPLICIT REAL*8(A-H,O-Z)
      SAVE
      COMPLEX*16 CLOGZ,H0,H0P,J0,J0P,P0Z,P1Z,Q0Z,Q1Z,Y0,Y0P,Z,ZI,ZI2,ZK,
     1FJ
      DIMENSION M(101), A1(25), A2(25), A3(25), A4(25), FJX(2)
      EQUIVALENCE (FJ,FJX)
      DATA PI,GAMMA,C1,C2,C3,P10,P20/3.141592654,.5772156649,-.024578509
     15,.3674669052,.7978845608,.0703125,.1121520996/
      DATA Q10,Q20,P11,P21,Q11,Q21/.125,.0732421875,.1171875,.1441955566
     1,.375,.1025390625/
      DATA POF,INIT/.7853981635,0/,FJX/0.,1./
      IF (INIT.EQ.0) GO TO 5
1     ZMS=Z*DCONJG(Z)
      IF (ZMS.NE.0.) GO TO 2
      WRITE(*,9)
      STOP
2     IB=0
      IF (ZMS.GT.16.81) GO TO 4
      IF (ZMS.GT.16.) IB=1
!     SERIES EXPANSION
      IZ=1.+ZMS
      MIZ=M(IZ)
      J0=(1.,0.)
      J0P=J0
      Y0=(0.,0.)
      Y0P=Y0
      ZK=J0
      ZI=Z*Z
      DO 3 K=1,MIZ
      ZK=ZK*A1(K)*ZI
      J0=J0+ZK
      J0P=J0P+A2(K)*ZK
      Y0=Y0+A3(K)*ZK
3     Y0P=Y0P+A4(K)*ZK
      J0P=-.5*Z*J0P
      CLOGZ=LOG(.5*Z)
      Y0=(2.*J0*CLOGZ-Y0)/PI+C2
      Y0P=(2./Z+2.*J0P*CLOGZ+.5*Y0P*Z)/PI+C1*Z
      H0=J0+FJ*Y0
      H0P=J0P+FJ*Y0P
      IF (IB.EQ.0) RETURN
      Y0=H0
      Y0P=H0P
!     ASYMPTOTIC EXPANSION
4     ZI=1./Z
      ZI2=ZI*ZI
      P0Z=1.+(P20*ZI2-P10)*ZI2
      P1Z=1.+(P11-P21*ZI2)*ZI2
      Q0Z=(Q20*ZI2-Q10)*ZI
      Q1Z=(Q11-Q21*ZI2)*ZI
      ZK=EXP(FJ*(Z-POF))*SQRT(ZI)*C3
      H0=ZK*(P0Z+FJ*Q0Z)
      H0P=FJ*ZK*(P1Z+FJ*Q1Z)
      IF (IB.EQ.0) RETURN
      ZMS=COS((SQRT(ZMS)-4.)*31.41592654)
      H0=.5*(Y0*(1.+ZMS)+H0*(1.-ZMS))
      H0P=.5*(Y0P*(1.+ZMS)+H0P*(1.-ZMS))
      RETURN

!     INITIALIZATION OF CONSTANTS
5     PSI=-GAMMA
      DO 6 K=1,25
      A1(K)=-.25D0/(K*K)
      A2(K)=1.D0/(K+1.D0)
      PSI=PSI+1.D0/K
      A3(K)=PSI+PSI
6     A4(K)=(PSI+PSI+1.D0/(K+1.D0))/(K+1.D0)
      DO 8 I=1,101
      TEST=1.D0
      DO 7 K=1,24
      INIT=K
      TEST=-TEST*I*A1(K)
      IF (TEST*A3(K).LT.1.D-6) GO TO 8
7     CONTINUE
8     M(I)=INIT
      GO TO 1
!
9     FORMAT (34H ERROR - HANKEL NOT VALID FOR Z=0.)
      END

!***********************************************************************
!----------------------------------------------------------------------------

      SUBROUTINE LAMBDA (T,XLAM,DXLAM)
!***********************************************************************
!
!     COMPUTE INTEGRATION PARAMETER XLAM=LAMBDA FROM PARAMETER T.
!
      IMPLICIT REAL*8(A-H,O-Z)
      SAVE
      COMPLEX*16 A,B,XLAM,DXLAM
      COMMON /CNTOUR/ A,B
      DXLAM=B-A
      XLAM=A+DXLAM*T
      RETURN
      END

!***********************************************************************
!----------------------------------------------------------------------------

      SUBROUTINE ROM1 (N,SUM,NX)
!***********************************************************************
!
!     ROM1 INTEGRATES THE 6 SOMMERFELD INTEGRALS FROM A TO B IN LAMBDA.
!     THE METHOD OF VARIABLE INTERVAL WIDTH ROMBERG INTEGRATION IS USED.
!
      IMPLICIT REAL*8(A-H,O-Z)
      SAVE
      COMPLEX*16 A,B,SUM,G1,G2,G3,G4,G5,T00,T01,T10,T02,T11,T20
      COMMON /CNTOUR/ A,B
      DIMENSION SUM(6), G1(6), G2(6), G3(6), G4(6), G5(6), T01(6), T10(6
     1), T20(6)
      DATA NM,NTS,RX/131072,4,1.E-4/
      LSTEP=0
      Z=0.
      ZE=1.
      S=1.
      EP=S/(1.E4*NM)
      ZEND=ZE-EP
      DO 1 I=1,N
1     SUM(I)=(0.,0.)
      NS=NX
      NT=0
      CALL SAOA (Z,G1)
2     DZ=S/NS
      IF (Z+DZ.LE.ZE) GO TO 3
      DZ=ZE-Z
      IF (DZ.LE.EP) GO TO 17
3     DZOT=DZ*.5
      CALL SAOA (Z+DZOT,G3)
      CALL SAOA (Z+DZ,G5)
4     NOGO=0
      DO 5 I=1,N
      T00=(G1(I)+G5(I))*DZOT
      T01(I)=(T00+DZ*G3(I))*.5
      T10(I)=(4.*T01(I)-T00)/3.
!     TEST CONVERGENCE OF 3 POINT ROMBERG RESULT
      CALL TEST (DREAL(T01(I)),DREAL(T10(I)),TR,DIMAG(T01(I)),DIMAG(T10
     1(I)),TI,0.d0)
      IF (TR.GT.RX.OR.TI.GT.RX) NOGO=1
5     CONTINUE
      IF (NOGO.NE.0) GO TO 7
      DO 6 I=1,N
6     SUM(I)=SUM(I)+T10(I)
      NT=NT+2
      GO TO 11
7     CALL SAOA (Z+DZ*.25,G2)
      CALL SAOA (Z+DZ*.75,G4)
      NOGO=0
      DO 8 I=1,N
      T02=(T01(I)+DZOT*(G2(I)+G4(I)))*.5
      T11=(4.*T02-T01(I))/3.
      T20(I)=(16.*T11-T10(I))/15.
!     TEST CONVERGENCE OF 5 POINT ROMBERG RESULT
      CALL TEST (DREAL(T11),DREAL(T20(I)),TR,DIMAG(T11),DIMAG(T20(I)),TI
     1,0.d0)
      IF (TR.GT.RX.OR.TI.GT.RX) NOGO=1
8     CONTINUE
      IF (NOGO.NE.0) GO TO 13
9     DO 10 I=1,N
10    SUM(I)=SUM(I)+T20(I)
      NT=NT+1
11    Z=Z+DZ
      IF (Z.GT.ZEND) GO TO 17
      DO 12 I=1,N
12    G1(I)=G5(I)
      IF (NT.LT.NTS.OR.NS.LE.NX) GO TO 2
      NS=NS/2
      NT=1
      GO TO 2
13    NT=0
      IF (NS.LT.NM) GO TO 15
      IF (LSTEP.EQ.1) GO TO 9
      LSTEP=1
      CALL LAMBDA (Z,T00,T11)
      WRITE(*,18) T00
      WRITE(*,19) Z,DZ,A,B
      DO 14 I=1,N
14    WRITE(*,19) G1(I),G2(I),G3(I),G4(I),G5(I)
      GO TO 9
15    NS=NS*2
      DZ=S/NS
      DZOT=DZ*.5
      DO 16 I=1,N
      G5(I)=G3(I)
16    G3(I)=G2(I)
      GO TO 4
17    CONTINUE
      RETURN
!
18    FORMAT (38H ROM1 -- STEP SIZE LIMITED AT LAMBDA =,1P2E12.5)
19    FORMAT (1X,1P10E12.5)
      END

!***********************************************************************
!----------------------------------------------------------------------------

      SUBROUTINE SAOA (T,ANS)
!***********************************************************************
!
!     SAOA COMPUTES THE INTEGRAND FOR EACH OF THE 6
!     SOMMERFELD INTEGRALS FOR SOURCE AND OBSERVER ABOVE GROUND
!
      IMPLICIT REAL*8(A-H,O-Z)
      SAVE
      COMPLEX*16 ANS,XL,DXL,CGAM1,CGAM2,B0,B0P,COM,CK1,CK1SQ,CKSM,CT1,
     1CT2,CT3,DGAM,DEN1,DEN2
      COMMON /EVLCOM/ CKSM,CT1,CT2,CT3,CK1,CK1SQ,CK2,CK2SQ,TKMAG,TSMAG,C
     1K1R,ZPH,RHO,JH
      DIMENSION ANS(6)
      CALL LAMBDA (T,XL,DXL)
      IF (JH.GT.0) GO TO 1
!     BESSEL FUNCTION FORM
      CALL BESSEL (XL*RHO,B0,B0P)
      B0=2.*B0
      B0P=2.*B0P
      CGAM1=SQRT(XL*XL-CK1SQ)
      CGAM2=SQRT(XL*XL-CK2SQ)
      IF (DREAL(CGAM1).EQ.0.) CGAM1=DCMPLX(0.D0,-ABS(DIMAG(CGAM1)))
      IF (DREAL(CGAM2).EQ.0.) CGAM2=DCMPLX(0.D0,-ABS(DIMAG(CGAM2)))
      GO TO 2
!     HANKEL FUNCTION FORM
1     CALL HANKEL (XL*RHO,B0,B0P)
      COM=XL-CK1
      CGAM1=SQRT(XL+CK1)*SQRT(COM)
      IF (DREAL(COM).LT.0..AND.DIMAG(COM).GE.0.) CGAM1=-CGAM1
      COM=XL-CK2
      CGAM2=SQRT(XL+CK2)*SQRT(COM)
      IF (DREAL(COM).LT.0..AND.DIMAG(COM).GE.0.) CGAM2=-CGAM2
2     XLR=XL*DCONJG(XL)
      IF (XLR.LT.TSMAG) GO TO 3
      IF (DIMAG(XL).LT.0.) GO TO 4
      XLR=DREAL(XL)
      IF (XLR.LT.CK2) GO TO 5
      IF (XLR.GT.CK1R) GO TO 4
3     DGAM=CGAM2-CGAM1
      GO TO 7
4     SIGN=1.
      GO TO 6
5     SIGN=-1.
6     DGAM=1./(XL*XL)
      DGAM=SIGN*((CT3*DGAM+CT2)*DGAM+CT1)/XL
7     DEN2=CKSM*DGAM/(CGAM2*(CK1SQ*CGAM2+CK2SQ*CGAM1))
      DEN1=1./(CGAM1+CGAM2)-CKSM/CGAM2
      COM=DXL*XL*EXP(-CGAM2*ZPH)
      ANS(6)=COM*B0*DEN1/CK1
      COM=COM*DEN2
      IF (RHO.EQ.0.) GO TO 8
      B0P=B0P/RHO
      ANS(1)=-COM*XL*(B0P+B0*XL)
      ANS(4)=COM*XL*B0P
      GO TO 9
8     ANS(1)=-COM*XL*XL*.5
      ANS(4)=ANS(1)
9     ANS(2)=COM*CGAM2*CGAM2*B0
      ANS(3)=-ANS(4)*CGAM2*RHO
      ANS(5)=COM*B0
      RETURN
      END

!***********************************************************************
      SUBROUTINE ARC (ITG,NS,RADA,ANG1,ANG2,RAD)
!***********************************************************************
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     ARC GENERATES SEGMENT GEOMETRY DATA FOR AN ARC OF NS SEGMENTS
!
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      DIMENSION X2(1), Y2(1), Z2(1)
      EQUIVALENCE (X2,SI), (Y2,ALP), (Z2,BET)
      DATA TA/.01745329252D+0/
      IST=N+1
      N=N+NS
      NP=N
      MP=M
      IPSYM=0
      IF (NS.LT.1) RETURN
      IF (ABS(ANG2-ANG1).LT.360.00001D+0) GO TO 1
      WRITE(3,3)
      STOP
1     ANG=ANG1*TA
      DANG=(ANG2-ANG1)*TA/NS
      XS1=RADA*COS(ANG)
      ZS1=RADA*SIN(ANG)
      DO 2 I=IST,N
      ANG=ANG+DANG
      XS2=RADA*COS(ANG)
      ZS2=RADA*SIN(ANG)
      X(I)=XS1
      Y(I)=0.
      Z(I)=ZS1
      X2(I)=XS2
      Y2(I)=0.
      Z2(I)=ZS2
      XS1=XS2
      ZS1=ZS2
      BI(I)=RAD
2     ITAG(I)=ITG
      RETURN
!
3     FORMAT (40H ERROR -- ARC ANGLE EXCEEDS 360. DEGREES)
      END
      FUNCTION ATGN2 (X,Y)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     ATGN2 IS ARCTANGENT FUNCTION MODIFIED TO RETURN 0. WHEN X=Y=0.
!
      IF (X) 3,1,3
1     IF (Y) 3,2,3
2     ATGN2=0.
      RETURN
3     ATGN2=ATAN2(X,Y)
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE BLCKOT (AR,NUNIT,IX1,IX2,NBLKS,NEOF)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     BLCKOT CONTROLS THE READING AND WRITING OF MATRIX BLOCKS ON FILES
!     FOR THE OUT-OF-CORE MATRIX SOLUTION.
!
      COMPLEX*16 AR
      DIMENSION AR(1)
      I1=(IX1+1)/2
      I2=(IX2+1)/2
1     WRITE (NUNIT) (AR(J),J=I1,I2)
      RETURN
      ENTRY BLCKIN(AR,NUNIT,IX1,IX2,NBLKS,NEOF)
      I1=(IX1+1)/2
      I2=(IX2+1)/2
      DO 2 I=1,NBLKS
      READ (NUNIT,END=3) (AR(J),J=I1,I2)
2     CONTINUE
      RETURN
3     WRITE(3,4)  NUNIT,NBLKS,NEOF
      IF (NEOF.NE.777) STOP
      NEOF=0
      RETURN
!
4     FORMAT (13H  EOF ON UNIT,I3,9H  NBLKS= ,I3,8H  NEOF= ,I5)
      END
!----------------------------------------------------------------------------

      SUBROUTINE CABC (CURX)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     CABC COMPUTES COEFFICIENTS OF THE CONSTANT (A), SINE (B), AND
!     COSINE (C) TERMS IN THE CURRENT INTERPOLATION FUNCTIONS FOR THE
!     CURRENT VECTOR CUR.
!
      COMPLEX*16 CUR,CURX,VQDS,CURD,CCJ,VSANT,VQD,CS1,CS2
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /CRNT/ AIR(MAXSEG),AII(MAXSEG),BIR(MAXSEG),BII(MAXSEG),
     &CIR(MAXSEG),CII(MAXSEG),CUR(3*MAXSEG)
      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      COMMON /VSORC/ VQD(nsmax),VSANT(nsmax),VQDS(nsmax),IVQD(nsmax),
     &ISANT(nsmax),IQDS(nsmax),NVQD,NSANT,NQDS			! av07

      COMMON /ANGL/ SALP(MAXSEG)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1)
      DIMENSION CURX(1), CCJX(2)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG)
      EQUIVALENCE (CCJ,CCJX)
      DATA TP/6.283185308D+0/,CCJX/0.,-0.01666666667D+0/
      IF (N.EQ.0) GO TO 6
      DO 1 I=1,N
      AIR(I)=0.
      AII(I)=0.
      BIR(I)=0.
      BII(I)=0.
      CIR(I)=0.
1     CII(I)=0.
      DO 2 I=1,N
      AR=DREAL(CURX(I))
      AI=DIMAG(CURX(I))
      CALL TBF (I,1)
      DO 2 JX=1,JSNO
      J=JCO(JX)
      AIR(J)=AIR(J)+AX(JX)*AR
      AII(J)=AII(J)+AX(JX)*AI
      BIR(J)=BIR(J)+BX(JX)*AR
      BII(J)=BII(J)+BX(JX)*AI
      CIR(J)=CIR(J)+CX(JX)*AR
2     CII(J)=CII(J)+CX(JX)*AI
      IF (NQDS.EQ.0) GO TO 4
      DO 3 IS=1,NQDS
      I=IQDS(IS)
      JX=ICON1(I)
      ICON1(I)=0
      CALL TBF (I,0)
      ICON1(I)=JX
      SH=SI(I)*.5
      CURD=CCJ*VQDS(IS)/((LOG(2.*SH/BI(I))-1.)*(BX(JSNO)*COS(TP*SH)+CX(
     1JSNO)*SIN(TP*SH))*WLAM)
      AR=DREAL(CURD)
      AI=DIMAG(CURD)
      DO 3 JX=1,JSNO
      J=JCO(JX)
      AIR(J)=AIR(J)+AX(JX)*AR
      AII(J)=AII(J)+AX(JX)*AI
      BIR(J)=BIR(J)+BX(JX)*AR
      BII(J)=BII(J)+BX(JX)*AI
      CIR(J)=CIR(J)+CX(JX)*AR
3     CII(J)=CII(J)+CX(JX)*AI
4     DO 5 I=1,N
5     CURX(I)=DCMPLX(AIR(I)+CIR(I),AII(I)+CII(I))
6     IF (M.EQ.0) RETURN
!     CONVERT SURFACE CURRENTS FROM T1,T2 COMPONENTS TO X,Y,Z COMPONENTS
      K=LD-M
      JCO1=N+2*M+1
      JCO2=JCO1+M
      DO 7 I=1,M
      K=K+1
      JCO1=JCO1-2
      JCO2=JCO2-3
      CS1=CURX(JCO1)
      CS2=CURX(JCO1+1)
      CURX(JCO2)=CS1*T1X(K)+CS2*T2X(K)
      CURX(JCO2+1)=CS1*T1Y(K)+CS2*T2Y(K)
7     CURX(JCO2+2)=CS1*T1Z(K)+CS2*T2Z(K)
      RETURN
      END
      FUNCTION CANG (Z)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     CANG RETURNS THE PHASE ANGLE OF A COMPLEX NUMBER IN DEGREES.
!
      COMPLEX*16 Z
      CANG=ATGN2(DIMAG(Z),DREAL(Z))*57.29577951D+0
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE CMNGF (CB,CC,CD,NB,NC,ND,RKHX,IEXKX)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     CMNGF FILLS INTERACTION MATRICIES B, C, AND D FOR N.G.F. SOLUTION
      COMPLEX*16 CB,CC,CD,ZARRAY,EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ZLOAD/ ZARRAY(MAXSEG),NLOAD,NLODF
      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      DIMENSION CB(NB,1), CC(NC,1), CD(ND,1)
      RKH=RKHX
      IEXK=IEXKX
      M1EQ=2*M1
      M2EQ=M1EQ+1
      MEQ=2*M
      NEQP=ND-NPCON*2
      NEQS=NEQP-NSCON
      NEQSP=NEQS+NC
      NEQN=NC+N-N1
      ITX=1
      IF (NSCON.GT.0) ITX=2
      IF (ICASX.EQ.1) GO TO 1
      REWIND 12
      REWIND 14
      REWIND 15
      IF (ICASX.GT.2) GO TO 5
1     DO 4 J=1,ND
      DO 2 I=1,ND
2     CD(I,J)=(0.,0.)
      DO 3 I=1,NB
      CB(I,J)=(0.,0.)
3     CC(I,J)=(0.,0.)
4     CONTINUE
5     IST=N-N1+1
      IT=NPBX
      ISV=-NPBX
!     LOOP THRU 24 FILLS B.  FOR ICASX=1 OR 2 ALSO FILLS D(WW), D(WS)
      DO 24 IBLK=1,NBBX
      ISV=ISV+NPBX
      IF (IBLK.EQ.NBBX) IT=NLBX
      IF (ICASX.LT.3) GO TO 7
      DO 6 J=1,ND
      DO 6 I=1,IT
6     CB(I,J)=(0.,0.)
7     I1=ISV+1
      I2=ISV+IT
      IN2=I2
      IF (IN2.GT.N1) IN2=N1
      IM1=I1-N1
      IM2=I2-N1
      IF (IM1.LT.1) IM1=1
      IMX=1
      IF (I1.LE.N1) IMX=N1-I1+2
      IF (N2.GT.N) GO TO 12
!     FILL B(WW),B(WS).  FOR ICASX=1,2 FILL D(WW),D(WS)
      DO 11 J=N2,N
      CALL TRIO (J)
      DO 9 I=1,JSNO
      JSS=JCO(I)
      IF (JSS.LT.N2) GO TO 8
!     SET JCO WHEN SOURCE IS NEW BASIS FUNCTION ON NEW SEGMENT
      JCO(I)=JSS-N1
      GO TO 9
!     SOURCE IS PORTION OF MODIFIED BASIS FUNCTION ON NEW SEGMENT
8     JCO(I)=NEQS+ICONX(JSS)
9     CONTINUE
      IF (I1.LE.IN2) CALL CMWW (J,I1,IN2,CB,NB,CB,NB,0)
      IF (IM1.LE.IM2) CALL CMWS (J,IM1,IM2,CB(IMX,1),NB,CB,NB,0)
      IF (ICASX.GT.2) GO TO 11
      CALL CMWW (J,N2,N,CD,ND,CD,ND,1)
      IF (M2.LE.M) CALL CMWS (J,M2EQ,MEQ,CD(1,IST),ND,CD,ND,1)
!     LOADING IN D(WW)
      IF (NLOAD.EQ.0) GO TO 11
      IR=J-N1
      EXK=ZARRAY(J)
      DO 10 I=1,JSNO
      JSS=JCO(I)
10    CD(JSS,IR)=CD(JSS,IR)-(AX(I)+CX(I))*EXK
11    CONTINUE
12    IF (NSCON.EQ.0) GO TO 20
!     FILL B(WW)PRIME
      DO 19 I=1,NSCON
      J=ISCON(I)
!     SOURCES ARE NEW OR MODIFIED BASIS FUNCTIONS ON OLD SEGMENTS WHICH
!     CONNECT TO NEW SEGMENTS
      CALL TRIO (J)
      JSS=0
      DO 15 IX=1,JSNO
      IR=JCO(IX)
      IF (IR.LT.N2) GO TO 13
      IR=IR-N1
      GO TO 14
13    IR=ICONX(IR)
      IF (IR.EQ.0) GO TO 15
      IR=NEQS+IR
14    JSS=JSS+1
      JCO(JSS)=IR
      AX(JSS)=AX(IX)
      BX(JSS)=BX(IX)
      CX(JSS)=CX(IX)
15    CONTINUE
      JSNO=JSS
      IF (I1.LE.IN2) CALL CMWW (J,I1,IN2,CB,NB,CB,NB,0)
      IF (IM1.LE.IM2) CALL CMWS (J,IM1,IM2,CB(IMX,1),NB,CB,NB,0)
!     SOURCE IS SINGULAR COMPONENT OF PATCH CURRENT THAT IS PART OF
!     MODIFIED BASIS FUNCTION FOR OLD SEGMENT THAT CONNECTS TO A NEW
!     SEGMENT ON END OPPOSITE PATCH.
      IF (I1.LE.IN2) CALL CMSW (J,I,I1,IN2,CB,CB,0,NB,-1)
      IF (NLODF.EQ.0) GO TO 17
      JX=J-ISV
      IF (JX.LT.1.OR.JX.GT.IT) GO TO 17
      EXK=ZARRAY(J)
      DO 16 IX=1,JSNO
      JSS=JCO(IX)
16    CB(JX,JSS)=CB(JX,JSS)-(AX(IX)+CX(IX))*EXK
!     SOURCES ARE PORTIONS OF MODIFIED BASIS FUNCTION J ON OLD SEGMENTS
!     EXCLUDING OLD SEGMENTS THAT DIRECTLY CONNECT TO NEW SEGMENTS.
17    CALL TBF (J,1)
      JSX=JSNO
      JSNO=1
      IR=JCO(1)
      JCO(1)=NEQS+I
      DO 19 IX=1,JSX
      IF (IX.EQ.1) GO TO 18
      IR=JCO(IX)
      AX(1)=AX(IX)
      BX(1)=BX(IX)
      CX(1)=CX(IX)
18    IF (IR.GT.N1) GO TO 19
      IF (ICONX(IR).NE.0) GO TO 19
      IF (I1.LE.IN2) CALL CMWW (IR,I1,IN2,CB,NB,CB,NB,0)
      IF (IM1.LE.IM2) CALL CMWS (IR,IM1,IM2,CB(IMX,1),NB,CB,NB,0)
!     LOADING FOR B(WW)PRIME
      IF (NLODF.EQ.0) GO TO 19
      JX=IR-ISV
      IF (JX.LT.1.OR.JX.GT.IT) GO TO 19
      EXK=ZARRAY(IR)
      JSS=JCO(1)
      CB(JX,JSS)=CB(JX,JSS)-(AX(1)+CX(1))*EXK
19    CONTINUE
20    IF (NPCON.EQ.0) GO TO 22
      JSS=NEQP
!     FILL B(SS)PRIME TO SET OLD PATCH BASIS FUNCTIONS TO ZERO FOR
!     PATCHES THAT CONNECT TO NEW SEGMENTS
      DO 21 I=1,NPCON
      IX=IPCON(I)*2+N1-ISV
      IR=IX-1
      JSS=JSS+1
      IF (IR.GT.0.AND.IR.LE.IT) CB(IR,JSS)=(1.,0.)
      JSS=JSS+1
      IF (IX.GT.0.AND.IX.LE.IT) CB(IX,JSS)=(1.,0.)
21    CONTINUE
22    IF (M2.GT.M) GO TO 23
!     FILL B(SW) AND B(SS)
      IF (I1.LE.IN2) CALL CMSW (M2,M,I1,IN2,CB(1,IST),CB,N1,NB,0)
      IF (IM1.LE.IM2) CALL CMSS (M2,M,IM1,IM2,CB(IMX,IST),NB,0)
23    IF (ICASX.EQ.1) GO TO 24
      WRITE (14) ((CB(I,J),I=1,IT),J=1,ND)
24    CONTINUE
!     FILLING B COMPLETE.  START ON C AND D
      IT=NPBL
      ISV=-NPBL
      DO 43 IBLK=1,NBBL
      ISV=ISV+NPBL
      ISVV=ISV+NC
      IF (IBLK.EQ.NBBL) IT=NLBL
      IF (ICASX.LT.3) GO TO 27
      DO 26 J=1,IT
      DO 25 I=1,NC
25    CC(I,J)=(0.,0.)
      DO 26 I=1,ND
26    CD(I,J)=(0.,0.)
27    I1=ISVV+1
      I2=ISVV+IT
      IN1=I1-M1EQ
      IN2=I2-M1EQ
      IF (IN2.GT.N) IN2=N
      IM1=I1-N
      IM2=I2-N
      IF (IM1.LT.M2EQ) IM1=M2EQ
      IF (IM2.GT.MEQ) IM2=MEQ
      IMX=1
      IF (IN1.LE.IN2) IMX=NEQN-I1+2
      IF (ICASX.LT.3) GO TO 32
      IF (N2.GT.N) GO TO 32
!     SAME AS DO 24 LOOP TO FILL D(WW) FOR ICASX GREATER THAN 2
      DO 31 J=N2,N
      CALL TRIO (J)
      DO 29 I=1,JSNO
      JSS=JCO(I)
      IF (JSS.LT.N2) GO TO 28
      JCO(I)=JSS-N1
      GO TO 29
28    JCO(I)=NEQS+ICONX(JSS)
29    CONTINUE
      IF (IN1.LE.IN2) CALL CMWW (J,IN1,IN2,CD,ND,CD,ND,1)
      IF (IM1.LE.IM2) CALL CMWS (J,IM1,IM2,CD(1,IMX),ND,CD,ND,1)
      IF (NLOAD.EQ.0) GO TO 31
      IR=J-N1-ISV
      IF (IR.LT.1.OR.IR.GT.IT) GO TO 31
      EXK=ZARRAY(J)
      DO 30 I=1,JSNO
      JSS=JCO(I)
30    CD(JSS,IR)=CD(JSS,IR)-(AX(I)+CX(I))*EXK
31    CONTINUE
32    IF (M2.GT.M) GO TO 33
!     FILL D(SW) AND D(SS)
      IF (IN1.LE.IN2) CALL CMSW (M2,M,IN1,IN2,CD(IST,1),CD,N1,ND,1)
      IF (IM1.LE.IM2) CALL CMSS (M2,M,IM1,IM2,CD(IST,IMX),ND,1)
33    IF (N1.LT.1) GO TO 39
!     FILL C(WW),C(WS), D(WW)PRIME, AND D(WS)PRIME.
      DO 37 J=1,N1
      CALL TRIO (J)
      IF (NSCON.EQ.0) GO TO 36
      DO 35 IX=1,JSNO
      JSS=JCO(IX)
      IF (JSS.LT.N2) GO TO 34
      JCO(IX)=JSS+M1EQ
      GO TO 35
34    IR=ICONX(JSS)
      IF (IR.NE.0) JCO(IX)=NEQSP+IR
35    CONTINUE
36    IF (IN1.LE.IN2) CALL CMWW (J,IN1,IN2,CC,NC,CD,ND,ITX)
      IF (IM1.LE.IM2) CALL CMWS (J,IM1,IM2,CC(1,IMX),NC,CD(1,IMX),ND,ITX
     1)
37    CONTINUE
      IF (NSCON.EQ.0) GO TO 39
!     FILL C(WW)PRIME
      DO 38 IX=1,NSCON
      IR=ISCON(IX)
      JSS=NEQS+IX-ISV
      IF (JSS.GT.0.AND.JSS.LE.IT) CC(IR,JSS)=(1.,0.)
38    CONTINUE
39    IF (NPCON.EQ.0) GO TO 41
      JSS=NEQP-ISV
!     FILL C(SS)PRIME
      DO 40 I=1,NPCON
      IX=IPCON(I)*2+N1
      IR=IX-1
      JSS=JSS+1
      IF (JSS.GT.0.AND.JSS.LE.IT) CC(IR,JSS)=(1.,0.)
      JSS=JSS+1
      IF (JSS.GT.0.AND.JSS.LE.IT) CC(IX,JSS)=(1.,0.)
40    CONTINUE
41    IF (M1.LT.1) GO TO 42
!     FILL C(SW) AND C(SS)
      IF (IN1.LE.IN2) CALL CMSW (1,M1,IN1,IN2,CC(N2,1),CC,0,NC,1)
      IF (IM1.LE.IM2) CALL CMSS (1,M1,IM1,IM2,CC(N2,IMX),NC,1)
42    CONTINUE
      IF (ICASX.EQ.1) GO TO 43
      WRITE (12) ((CD(J,I),J=1,ND),I=1,IT)
      WRITE (15) ((CC(J,I),J=1,NC),I=1,IT)
43    CONTINUE
      IF(ICASX.EQ.1)RETURN
      REWIND 12
      REWIND 14
      REWIND 15
      RETURN
      END

!----------------------------------------------------------------------------

      SUBROUTINE CMSET (NROW,CM,RKHX,IEXKX)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     CMSET SETS UP THE COMPLEX STRUCTURE MATRIX IN THE ARRAY CM
!
      COMPLEX*16 CM,ZARRAY,ZAJ,EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC,SSX,
     &D,DETER
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      COMMON /SMAT/ SSX(16,16)
      COMMON /SCRATM/ D(2*MAXSEG)
      COMMON /ZLOAD/ ZARRAY(MAXSEG),NLOAD,NLODF

      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      DIMENSION CM(NROW,1)
      MP2=2*MP
      NPEQ=NP+MP2
      NEQ=N+2*M
      NOP=NEQ/NPEQ
      IF (ICASE.GT.2) REWIND 11
      RKH=RKHX
      IEXK=IEXKX
      IOUT=2*NPBLK*NROW
      IT=NPBLK
!
!     CYCLE OVER MATRIX BLOCKS
!
      DO 13 IXBLK1=1,NBLOKS
      ISV=(IXBLK1-1)*NPBLK
      IF (IXBLK1.EQ.NBLOKS) IT=NLAST
      DO 1 I=1,NROW
      DO 1 J=1,IT
1     CM(I,J)=(0.,0.)
      I1=ISV+1
      I2=ISV+IT
      IN2=I2
      IF (IN2.GT.NP) IN2=NP
      IM1=I1-NP
      IM2=I2-NP
      IF (IM1.LT.1) IM1=1
      IST=1
      IF (I1.LE.NP) IST=NP-I1+2
      IF (N.EQ.0) GO TO 5
!
!     WIRE SOURCE LOOP
!
      DO 4 J=1,N
      CALL TRIO (J)
      DO 2 I=1,JSNO
      IJ=JCO(I)
2     JCO(I)=((IJ-1)/NP)*MP2+IJ
      IF (I1.LE.IN2) CALL CMWW (J,I1,IN2,CM,NROW,CM,NROW,1)
      IF (IM1.LE.IM2) CALL CMWS (J,IM1,IM2,CM(1,IST),NROW,CM,NROW,1)
      IF (NLOAD.EQ.0) GO TO 4
!
!     MATRIX ELEMENTS MODIFIED BY LOADING
!
      IF (J.GT.NP) GO TO 4
      IPR=J-ISV
      IF (IPR.LT.1.OR.IPR.GT.IT) GO TO 4
      ZAJ=ZARRAY(J)
      DO 3 I=1,JSNO
      JSS=JCO(I)
3     CM(JSS,IPR)=CM(JSS,IPR)-(AX(I)+CX(I))*ZAJ
4     CONTINUE
5     IF (M.EQ.0) GO TO 7
!     MATRIX ELEMENTS FOR PATCH CURRENT SOURCES
      JM1=1-MP
      JM2=0
      JST=1-MP2
      DO 6 I=1,NOP
      JM1=JM1+MP
      JM2=JM2+MP
      JST=JST+NPEQ
      IF (I1.LE.IN2) CALL CMSW (JM1,JM2,I1,IN2,CM(JST,1),CM,0,NROW,1)
      IF (IM1.LE.IM2) CALL CMSS (JM1,JM2,IM1,IM2,CM(JST,IST),NROW,1)
6     CONTINUE
7     IF (ICASE.EQ.1) GO TO 13
      IF (ICASE.EQ.3) GO TO 12
!     COMBINE ELEMENTS FOR SYMMETRY MODES
      DO 11 I=1,IT
      DO 11 J=1,NPEQ
      DO 8 K=1,NOP
      KA=J+(K-1)*NPEQ
8     D(K)=CM(KA,I)
      DETER=D(1)
      DO 9 KK=2,NOP
9     DETER=DETER+D(KK)
      CM(J,I)=DETER
      DO 11 K=2,NOP
      KA=J+(K-1)*NPEQ
      DETER=D(1)
      DO 10 KK=2,NOP
10    DETER=DETER+D(KK)*SSX(K,KK)
      CM(KA,I)=DETER
11    CONTINUE
      IF (ICASE.LT.3) GO TO 13
!     WRITE BLOCK FOR OUT-OF-CORE CASES.
12    CALL BLCKOT (CM,11,1,IOUT,1,31)
13    CONTINUE
      IF (ICASE.GT.2) REWIND 11
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE CMSS (J1,J2,IM1,IM2,CM,NROW,ITRP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     CMSS COMPUTES MATRIX ELEMENTS FOR SURFACE-SURFACE INTERACTIONS.
      COMPLEX*16 G11,G12,G21,G22,CM,EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      DIMENSION CM(NROW,1)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG)
      EQUIVALENCE (T1XJ,CABJ), (T1YJ,SABJ), (T1ZJ,SALPJ), (T2XJ,B), (T2Y
     1J,IND1), (T2ZJ,IND2)
      LDP=LD+1
      I1=(IM1+1)/2
      I2=(IM2+1)/2
      ICOMP=I1*2-3
      II1=-1
      IF (ICOMP+2.LT.IM1) II1=-2
!     LOOP OVER OBSERVATION PATCHES
      DO 5 I=I1,I2
      IL=LDP-I
      ICOMP=ICOMP+2
      II1=II1+2
      II2=II1+1
      T1XI=T1X(IL)*SALP(IL)
      T1YI=T1Y(IL)*SALP(IL)
      T1ZI=T1Z(IL)*SALP(IL)
      T2XI=T2X(IL)*SALP(IL)
      T2YI=T2Y(IL)*SALP(IL)
      T2ZI=T2Z(IL)*SALP(IL)
      XI=X(IL)
      YI=Y(IL)
      ZI=Z(IL)
      JJ1=-1
!     LOOP OVER SOURCE PATCHES
      DO 5 J=J1,J2
      JL=LDP-J
      JJ1=JJ1+2
      JJ2=JJ1+1
      S=BI(JL)
      XJ=X(JL)
      YJ=Y(JL)
      ZJ=Z(JL)
      T1XJ=T1X(JL)
      T1YJ=T1Y(JL)
      T1ZJ=T1Z(JL)
      T2XJ=T2X(JL)
      T2YJ=T2Y(JL)
      T2ZJ=T2Z(JL)
      CALL HINTG (XI,YI,ZI)
      G11=-(T2XI*EXK+T2YI*EYK+T2ZI*EZK)
      G12=-(T2XI*EXS+T2YI*EYS+T2ZI*EZS)
      G21=-(T1XI*EXK+T1YI*EYK+T1ZI*EZK)
      G22=-(T1XI*EXS+T1YI*EYS+T1ZI*EZS)
      IF (I.NE.J) GO TO 1
      G11=G11-.5
      G22=G22+.5
1     IF (ITRP.NE.0) GO TO 3
!     NORMAL FILL
      IF (ICOMP.LT.IM1) GO TO 2
      CM(II1,JJ1)=G11
      CM(II1,JJ2)=G12
2     IF (ICOMP.GE.IM2) GO TO 5
      CM(II2,JJ1)=G21
      CM(II2,JJ2)=G22
      GO TO 5
!     TRANSPOSED FILL
3     IF (ICOMP.LT.IM1) GO TO 4
      CM(JJ1,II1)=G11
      CM(JJ2,II1)=G12
4     IF (ICOMP.GE.IM2) GO TO 5
      CM(JJ1,II2)=G21
      CM(JJ2,II2)=G22
5     CONTINUE
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE CMSW (J1,J2,I1,I2,CM,CW,NCW,NROW,ITRP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     COMPUTES MATRIX ELEMENTS FOR E ALONG WIRES DUE TO PATCH CURRENT
      COMPLEX*16 CM,ZRATI,ZRATI2,T1,EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC
     1,EMEL,CW,FRATI
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND

      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      DIMENSION CAB(1), SAB(1), CM(NROW,1), CW(NROW,1)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1), EMEL(9)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG), (CAB,ALP), (SAB,BET)
      EQUIVALENCE (T1XJ,CABJ), (T1YJ,SABJ), (T1ZJ,SALPJ), (T2XJ,B), (T2Y
     1J,IND1), (T2ZJ,IND2)
      DATA PI/3.141592654D+0/
      LDP=LD+1
      NEQS=N-N1+2*(M-M1)
      IF (ITRP.LT.0) GO TO 13
      K=0
      ICGO=1
!     OBSERVATION LOOP
      DO 12 I=I1,I2
      K=K+1
      XI=X(I)
      YI=Y(I)
      ZI=Z(I)
      CABI=CAB(I)
      SABI=SAB(I)
      SALPI=SALP(I)
      IPCH=0
      IF (ICON1(I).LT.10000) GO TO 1
      IPCH=ICON1(I)-10000
      FSIGN=-1.
1     IF (ICON2(I).LT.10000) GO TO 2
      IPCH=ICON2(I)-10000
      FSIGN=1.
2     JL=0
!     SOURCE LOOP
      DO 12 J=J1,J2
      JS=LDP-J
      JL=JL+2
      T1XJ=T1X(JS)
      T1YJ=T1Y(JS)
      T1ZJ=T1Z(JS)
      T2XJ=T2X(JS)
      T2YJ=T2Y(JS)
      T2ZJ=T2Z(JS)
      XJ=X(JS)
      YJ=Y(JS)
      ZJ=Z(JS)
      S=BI(JS)
!     GROUND LOOP
      DO 12 IP=1,KSYMP
      IPGND=IP
      IF (IPCH.NE.J.AND.ICGO.EQ.1) GO TO 9
      IF (IP.EQ.2) GO TO 9
      IF (ICGO.GT.1) GO TO 6
      CALL PCINT (XI,YI,ZI,CABI,SABI,SALPI,EMEL)
      PY=PI*SI(I)*FSIGN
      PX=SIN(PY)
      PY=COS(PY)
      EXC=EMEL(9)*FSIGN
      CALL TRIO (I)
      IF (I.GT.N1) GO TO 3
      IL=NEQS+ICONX(I)
      GO TO 4
3     IL=I-NCW
      IF (I.LE.NP) IL=((IL-1)/NP)*2*MP+IL
4     IF (ITRP.NE.0) GO TO 5
      CW(K,IL)=CW(K,IL)+EXC*(AX(JSNO)+BX(JSNO)*PX+CX(JSNO)*PY)
      GO TO 6
5     CW(IL,K)=CW(IL,K)+EXC*(AX(JSNO)+BX(JSNO)*PX+CX(JSNO)*PY)
6     IF (ITRP.NE.0) GO TO 7
      CM(K,JL-1)=EMEL(ICGO)
      CM(K,JL)=EMEL(ICGO+4)
      GO TO 8
7     CM(JL-1,K)=EMEL(ICGO)
      CM(JL,K)=EMEL(ICGO+4)
8     ICGO=ICGO+1
      IF (ICGO.EQ.5) ICGO=1
      GO TO 11
9     CALL UNERE (XI,YI,ZI)
      IF (ITRP.NE.0) GO TO 10
!     NORMAL FILL
      CM(K,JL-1)=CM(K,JL-1)+EXK*CABI+EYK*SABI+EZK*SALPI
      CM(K,JL)=CM(K,JL)+EXS*CABI+EYS*SABI+EZS*SALPI
      GO TO 11
!     TRANSPOSED FILL
10    CM(JL-1,K)=CM(JL-1,K)+EXK*CABI+EYK*SABI+EZK*SALPI
      CM(JL,K)=CM(JL,K)+EXS*CABI+EYS*SABI+EZS*SALPI
11    CONTINUE
12    CONTINUE
      RETURN
!     FOR OLD SEG. CONNECTING TO OLD PATCH ON ONE END AND NEW SEG. ON
!     OTHER END INTEGRATE SINGULAR COMPONENT (9) OF SURFACE CURRENT ONLY
13    IF (J1.LT.I1.OR.J1.GT.I2) GO TO 16
      IPCH=ICON1(J1)
      IF (IPCH.LT.10000) GO TO 14
      IPCH=IPCH-10000
      FSIGN=-1.
      GO TO 15
14    IPCH=ICON2(J1)
      IF (IPCH.LT.10000) GO TO 16
      IPCH=IPCH-10000
      FSIGN=1.
15    IF (IPCH.GT.M1) GO TO 16
      JS=LDP-IPCH
      IPGND=1
      T1XJ=T1X(JS)
      T1YJ=T1Y(JS)
      T1ZJ=T1Z(JS)
      T2XJ=T2X(JS)
      T2YJ=T2Y(JS)
      T2ZJ=T2Z(JS)
      XJ=X(JS)
      YJ=Y(JS)
      ZJ=Z(JS)
      S=BI(JS)
      XI=X(J1)
      YI=Y(J1)
      ZI=Z(J1)
      CABI=CAB(J1)
      SABI=SAB(J1)
      SALPI=SALP(J1)
      CALL PCINT (XI,YI,ZI,CABI,SABI,SALPI,EMEL)
      PY=PI*SI(J1)*FSIGN
      PX=SIN(PY)
      PY=COS(PY)
      EXC=EMEL(9)*FSIGN
      IL=JCO(JSNO)
      K=J1-I1+1
      CW(K,IL)=CW(K,IL)+EXC*(AX(JSNO)+BX(JSNO)*PX+CX(JSNO)*PY)
16    RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE CMWS (J,I1,I2,CM,NR,CW,NW,ITRP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     CMWS COMPUTES MATRIX ELEMENTS FOR WIRE-SURFACE INTERACTIONS
!
      COMPLEX*16 CM,CW,ETK,ETS,ETC,EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)

      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      DIMENSION CM(NR,1), CW(NW,1), CAB(1), SAB(1)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1)
      EQUIVALENCE (CAB,ALP), (SAB,BET), (T1X,SI), (T1Y,ALP), (T1Z,BET)
      EQUIVALENCE (T2X,ICON1), (T2Y,ICON2), (T2Z,ITAG)
      LDP=LD+1
      S=SI(J)
      B=BI(J)
      XJ=X(J)
      YJ=Y(J)
      ZJ=Z(J)
      CABJ=CAB(J)
      SABJ=SAB(J)
      SALPJ=SALP(J)
!
!     OBSERVATION LOOP
!
      IPR=0
      DO 9 I=I1,I2
      IPR=IPR+1
      IPATCH=(I+1)/2
      IK=I-(I/2)*2
      IF (IK.EQ.0.AND.IPR.NE.1) GO TO 1
      JS=LDP-IPATCH
      XI=X(JS)
      YI=Y(JS)
      ZI=Z(JS)
      CALL HSFLD (XI,YI,ZI,0.D0)
      IF (IK.EQ.0) GO TO 1
      TX=T2X(JS)
      TY=T2Y(JS)
      TZ=T2Z(JS)
      GO TO 2
1     TX=T1X(JS)
      TY=T1Y(JS)
      TZ=T1Z(JS)
2     ETK=-(EXK*TX+EYK*TY+EZK*TZ)*SALP(JS)
      ETS=-(EXS*TX+EYS*TY+EZS*TZ)*SALP(JS)
      ETC=-(EXC*TX+EYC*TY+EZC*TZ)*SALP(JS)
!
!     FILL MATRIX ELEMENTS.  ELEMENT LOCATIONS DETERMINED BY CONNECTION
!     DATA.
!
      IF (ITRP.NE.0) GO TO 4
!     NORMAL FILL
      DO 3 IJ=1,JSNO
      JX=JCO(IJ)
3     CM(IPR,JX)=CM(IPR,JX)+ETK*AX(IJ)+ETS*BX(IJ)+ETC*CX(IJ)
      GO TO 9
4     IF (ITRP.EQ.2) GO TO 6
!     TRANSPOSED FILL
      DO 5 IJ=1,JSNO
      JX=JCO(IJ)
5     CM(JX,IPR)=CM(JX,IPR)+ETK*AX(IJ)+ETS*BX(IJ)+ETC*CX(IJ)
      GO TO 9
!     TRANSPOSED FILL - C(WS) AND D(WS)PRIME (=CW)
6     DO 8 IJ=1,JSNO
      JX=JCO(IJ)
      IF (JX.GT.NR) GO TO 7
      CM(JX,IPR)=CM(JX,IPR)+ETK*AX(IJ)+ETS*BX(IJ)+ETC*CX(IJ)
      GO TO 8
7     JX=JX-NR
      CW(JX,IPR)=CW(JX,IPR)+ETK*AX(IJ)+ETS*BX(IJ)+ETC*CX(IJ)
8     CONTINUE
9     CONTINUE
      RETURN
      END

!----------------------------------------------------------------------------

      SUBROUTINE CMWW (J,I1,I2,CM,NR,CW,NW,ITRP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     CMWW COMPUTES MATRIX ELEMENTS FOR WIRE-WIRE INTERACTIONS
!
      COMPLEX*16 CM,CW,ETK,ETS,ETC,EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)

      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      DIMENSION CM(NR,1), CW(NW,1), CAB(1), SAB(1)
      EQUIVALENCE (CAB,ALP), (SAB,BET)

!     SET SOURCE SEGMENT PARAMETERS

      S=SI(J)
      B=BI(J)
      XJ=X(J)
      YJ=Y(J)
      ZJ=Z(J)
      CABJ=CAB(J)
      SABJ=SAB(J)
      SALPJ=SALP(J)
      IF (IEXK.EQ.0) GO TO 16

!     DECIDE WETHER EXT. T.W. APPROX. CAN BE USED

      IPR=ICON1(J)
      IF(IPR.GT.10000)GO TO 5      !<---NEW, av016
      IF (IPR) 1,6,2

1     IPR=-IPR
      IF (-ICON1(IPR).NE.J) GO TO 7
      GO TO 4
2     IF (IPR.NE.J) GO TO 3
      IF (CABJ*CABJ+SABJ*SABJ.GT.1.D-8) GO TO 7
      GO TO 5
3     IF (ICON2(IPR).NE.J) GO TO 7
4     XI=ABS(CABJ*CAB(IPR)+SABJ*SAB(IPR)+SALPJ*SALP(IPR))
      IF (XI.LT.0.999999D+0) GO TO 7
      IF (ABS(BI(IPR)/B-1.).GT.1.D-6) GO TO 7
5     IND1=0
      GO TO 8
6     IND1=1
      GO TO 8
7     IND1=2

8     IPR=ICON2(J)
      IF(IPR.GT.10000)GO TO 15     !<---NEW, av016
      IF (IPR) 9,14,10

9     IPR=-IPR
      IF (-ICON2(IPR).NE.J) GO TO 15
      GO TO 12
10    IF (IPR.NE.J) GO TO 11
      IF (CABJ*CABJ+SABJ*SABJ.GT.1.D-8) GO TO 15
      GO TO 13
11    IF (ICON1(IPR).NE.J) GO TO 15
12    XI=ABS(CABJ*CAB(IPR)+SABJ*SAB(IPR)+SALPJ*SALP(IPR))
      IF (XI.LT.0.999999D+0) GO TO 15
      IF (ABS(BI(IPR)/B-1.).GT.1.D-6) GO TO 15
13    IND2=0
      GO TO 16
14    IND2=1
      GO TO 16
15    IND2=2
16    CONTINUE
!
!     OBSERVATION LOOP
!
      IPR=0
      DO 23 I=I1,I2
      IPR=IPR+1
      IJ=I-J
      XI=X(I)
      YI=Y(I)
      ZI=Z(I)
      AI=BI(I)
      CABI=CAB(I)
      SABI=SAB(I)
      SALPI=SALP(I)
      CALL EFLD (XI,YI,ZI,AI,IJ)
      ETK=EXK*CABI+EYK*SABI+EZK*SALPI
      ETS=EXS*CABI+EYS*SABI+EZS*SALPI
      ETC=EXC*CABI+EYC*SABI+EZC*SALPI
!
!     FILL MATRIX ELEMENTS.  ELEMENT LOCATIONS DETERMINED BY CONNECTION
!     DATA.
!
      IF (ITRP.NE.0) GO TO 18
!     NORMAL FILL
      DO 17 IJ=1,JSNO
      JX=JCO(IJ)
17    CM(IPR,JX)=CM(IPR,JX)+ETK*AX(IJ)+ETS*BX(IJ)+ETC*CX(IJ)
      GO TO 23
18    IF (ITRP.EQ.2) GO TO 20
!     TRANSPOSED FILL
      DO 19 IJ=1,JSNO
      JX=JCO(IJ)
19    CM(JX,IPR)=CM(JX,IPR)+ETK*AX(IJ)+ETS*BX(IJ)+ETC*CX(IJ)
      GO TO 23
!     TRANS. FILL FOR C(WW) - TEST FOR ELEMENTS FOR D(WW)PRIME.  (=CW)
20    DO 22 IJ=1,JSNO
      JX=JCO(IJ)
      IF (JX.GT.NR) GO TO 21
      CM(JX,IPR)=CM(JX,IPR)+ETK*AX(IJ)+ETS*BX(IJ)+ETC*CX(IJ)
      GO TO 22
21    JX=JX-NR
      CW(JX,IPR)=CW(JX,IPR)+ETK*AX(IJ)+ETS*BX(IJ)+ETC*CX(IJ)
22    CONTINUE
23    CONTINUE
      RETURN
      END

!----------------------------------------------------------------------------

      SUBROUTINE CONECT (IGND)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     CONNECT SETS UP SEGMENT CONNECTION DATA IN ARRAYS ICON1 AND ICON2
!     BY SEARCHING FOR SEGMENT ENDS THAT ARE IN CONTACT.
!
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM

      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      DIMENSION X2(1), Y2(1), Z2(1)
      EQUIVALENCE (X2,SI), (Y2,ALP), (Z2,BET)

      DATA SMIN/1.D-3/,NPMAX/10/

      NSCON=0
      NPCON=0
      IF (IGND.EQ.0) GO TO 3
      WRITE(3,54)
      IF (IGND.GT.0) WRITE(3,55)
      IF (IPSYM.NE.2) GO TO 1
      NP=2*NP
      MP=2*MP
1     IF (IABS(IPSYM).LE.2) GO TO 2
      NP=N
      MP=M
2     IF (NP.GT.N) STOP
      IF (NP.EQ.N.AND.MP.EQ.M) IPSYM=0
3     IF (N.EQ.0) GO TO 26
      DO 15 I=1,N
      ICONX(I)=0
      XI1=X(I)
      YI1=Y(I)
      ZI1=Z(I)
      XI2=X2(I)
      YI2=Y2(I)
      ZI2=Z2(I)
      SLEN=SQRT((XI2-XI1)**2+(YI2-YI1)**2+(ZI2-ZI1)**2)*SMIN
!
!     DETERMINE CONNECTION DATA FOR END 1 OF SEGMENT.
!
      IF (IGND.LT.1) GO TO 5
      IF (ZI1.GT.-SLEN) GO TO 4
      WRITE(3,56)  I
      STOP
4     IF (ZI1.GT.SLEN) GO TO 5
      ICON1(I)=I
      Z(I)=0.
      GO TO 9
5     IC=I
      DO 7 J=2,N
      IC=IC+1
      IF (IC.GT.N) IC=1
      SEP=ABS(XI1-X(IC))+ABS(YI1-Y(IC))+ABS(ZI1-Z(IC))
      IF (SEP.GT.SLEN) GO TO 6
      ICON1(I)=-IC
      GO TO 8
6     SEP=ABS(XI1-X2(IC))+ABS(YI1-Y2(IC))+ABS(ZI1-Z2(IC))
      IF (SEP.GT.SLEN) GO TO 7
      ICON1(I)=IC
      GO TO 8
7     CONTINUE
      IF (I.LT.N2.AND.ICON1(I).GT.10000) GO TO 8
      ICON1(I)=0
!
!     DETERMINE CONNECTION DATA FOR END 2 OF SEGMENT.
!
8     IF (IGND.LT.1) GO TO 12
9     IF (ZI2.GT.-SLEN) GO TO 10
      WRITE(3,56)  I
      STOP
10    IF (ZI2.GT.SLEN) GO TO 12
      IF (ICON1(I).NE.I) GO TO 11
      WRITE(3,57)  I
      STOP
11    ICON2(I)=I
      Z2(I)=0.
      GO TO 15
12    IC=I
      DO 14 J=2,N
      IC=IC+1
      IF (IC.GT.N) IC=1
      SEP=ABS(XI2-X(IC))+ABS(YI2-Y(IC))+ABS(ZI2-Z(IC))
      IF (SEP.GT.SLEN) GO TO 13
      ICON2(I)=IC
      GO TO 15
13    SEP=ABS(XI2-X2(IC))+ABS(YI2-Y2(IC))+ABS(ZI2-Z2(IC))
      IF (SEP.GT.SLEN) GO TO 14
      ICON2(I)=-IC
      GO TO 15
14    CONTINUE
      IF (I.LT.N2.AND.ICON2(I).GT.10000) GO TO 15
      ICON2(I)=0
15    CONTINUE
      IF (M.EQ.0) GO TO 26
!     FIND WIRE-SURFACE CONNECTIONS FOR NEW PATCHES
      IX=LD+1-M1
      I=M2
16    IF (I.GT.M) GO TO 20
      IX=IX-1
      XS=X(IX)
      YS=Y(IX)
      ZS=Z(IX)
      DO 18 ISEG=1,N
      XI1=X(ISEG)
      YI1=Y(ISEG)
      ZI1=Z(ISEG)
      XI2=X2(ISEG)
      YI2=Y2(ISEG)
      ZI2=Z2(ISEG)
      SLEN=(ABS(XI2-XI1)+ABS(YI2-YI1)+ABS(ZI2-ZI1))*SMIN
!     FOR FIRST END OF SEGMENT
      SEP=ABS(XI1-XS)+ABS(YI1-YS)+ABS(ZI1-ZS)
      IF (SEP.GT.SLEN) GO TO 17
!     CONNECTION - DIVIDE PATCH INTO 4 PATCHES AT PRESENT ARRAY LOC.
      ICON1(ISEG)=10000+I
      IC=0
      CALL SUBPH (I,IC,XI1,YI1,ZI1,XI2,YI2,ZI2,XA,YA,ZA,XS,YS,ZS)
      GO TO 19
17    SEP=ABS(XI2-XS)+ABS(YI2-YS)+ABS(ZI2-ZS)
      IF (SEP.GT.SLEN) GO TO 18
      ICON2(ISEG)=10000+I
      IC=0
      CALL SUBPH (I,IC,XI1,YI1,ZI1,XI2,YI2,ZI2,XA,YA,ZA,XS,YS,ZS)
      GO TO 19
18    CONTINUE
19    I=I+1
      GO TO 16
!     REPEAT SEARCH FOR NEW SEGMENTS CONNECTED TO NGF PATCHES.
20    IF (M1.EQ.0.OR.N2.GT.N) GO TO 26
      IX=LD+1
      I=1
21    IF (I.GT.M1) GO TO 25
      IX=IX-1
      XS=X(IX)
      YS=Y(IX)
      ZS=Z(IX)
      DO 23 ISEG=N2,N
      XI1=X(ISEG)
      YI1=Y(ISEG)
      ZI1=Z(ISEG)
      XI2=X2(ISEG)
      YI2=Y2(ISEG)
      ZI2=Z2(ISEG)
      SLEN=(ABS(XI2-XI1)+ABS(YI2-YI1)+ABS(ZI2-ZI1))*SMIN
      SEP=ABS(XI1-XS)+ABS(YI1-YS)+ABS(ZI1-ZS)
      IF (SEP.GT.SLEN) GO TO 22
      ICON1(ISEG)=10001+M
      IC=1
      NPCON=NPCON+1
      IPCON(NPCON)=I
      CALL SUBPH (I,IC,XI1,YI1,ZI1,XI2,YI2,ZI2,XA,YA,ZA,XS,YS,ZS)
      GO TO 24
22    SEP=ABS(XI2-XS)+ABS(YI2-YS)+ABS(ZI2-ZS)
      IF (SEP.GT.SLEN) GO TO 23
      ICON2(ISEG)=10001+M
      IC=1
      NPCON=NPCON+1
      IPCON(NPCON)=I
      CALL SUBPH (I,IC,XI1,YI1,ZI1,XI2,YI2,ZI2,XA,YA,ZA,XS,YS,ZS)
      GO TO 24
23    CONTINUE
24    I=I+1
      GO TO 21
25    IF (NPCON.LE.NPMAX) GO TO 26
      WRITE(3,62)  NPMAX
      STOP
26    WRITE(3,58)  N,NP,IPSYM
      IF (M.GT.0) WRITE(3,61)  M,MP
      ISEG=(N+M)/(NP+MP)
      IF (ISEG.EQ.1) GO TO 30
      IF (IPSYM) 28,27,29
27    STOP
28    WRITE(3,59) ISEG
      GO TO 30
29    IC=ISEG/2
      IF (ISEG.EQ.8) IC=3
      WRITE(3,60)  IC
30    IF (N.EQ.0) GO TO 48
      WRITE(3,50)
      ISEG=0
!     ADJUST CONNECTED SEG. ENDS TO EXACTLY COINCIDE.  PRINT JUNCTIONS
!     OF 3 OR MORE SEG.  ALSO FIND OLD SEG. CONNECTING TO NEW SEG.
      DO 44 J=1,N
      IEND=-1
      JEND=-1
      IX=ICON1(J)
      IC=1
      JCO(1)=-J
      XA=X(J)
      YA=Y(J)
      ZA=Z(J)
31    IF (IX.EQ.0) GO TO 43
      IF (IX.EQ.J) GO TO 43
      IF (IX.GT.10000) GO TO 43
      NSFLG=0
32    IF (IX) 33,49,34
33    IX=-IX
      GO TO 35
34    JEND=-JEND
35    IF (IX.EQ.J) GO TO 37
      IF (IX.LT.J) GO TO 43
      IC=IC+1
      IF (IC.GT.JMAX) GO TO 49
      JCO(IC)=IX*JEND
      IF (IX.GT.N1) NSFLG=1
      IF (JEND.EQ.1) GO TO 36
      XA=XA+X(IX)
      YA=YA+Y(IX)
      ZA=ZA+Z(IX)
      IX=ICON1(IX)
      GO TO 32
36    XA=XA+X2(IX)
      YA=YA+Y2(IX)
      ZA=ZA+Z2(IX)
      IX=ICON2(IX)
      GO TO 32
37    SEP=IC
      XA=XA/SEP
      YA=YA/SEP
      ZA=ZA/SEP
      DO 39 I=1,IC
      IX=JCO(I)
      IF (IX.GT.0) GO TO 38
      IX=-IX
      X(IX)=XA
      Y(IX)=YA
      Z(IX)=ZA
      GO TO 39
38    X2(IX)=XA
      Y2(IX)=YA
      Z2(IX)=ZA
39    CONTINUE
      IF (N1.EQ.0) GO TO 42
      IF (NSFLG.EQ.0) GO TO 42
      DO 41 I=1,IC
      IX=IABS(JCO(I))
      IF (IX.GT.N1) GO TO 41
      IF (ICONX(IX).NE.0) GO TO 41
      NSCON=NSCON+1
      IF (NSCON.LE.NSMAX) GO TO 40
      WRITE(3,62)  NSMAX
      STOP
40    ISCON(NSCON)=IX
      ICONX(IX)=NSCON
41    CONTINUE
42    IF (IC.LT.3) GO TO 43
      ISEG=ISEG+1
      WRITE(3,51) ISEG,(JCO(I),I=1,IC)
43    IF (IEND.EQ.1) GO TO 44
      IEND=1
      JEND=1
      IX=ICON2(J)
      IC=1
      JCO(1)=J
      XA=X2(J)
      YA=Y2(J)
      ZA=Z2(J)
      GO TO 31
44    CONTINUE
      IF (ISEG.EQ.0) WRITE(3,52)
      IF (N1.EQ.0.OR.M1.EQ.M) GO TO 48
!     FIND OLD SEGMENTS THAT CONNECT TO NEW PATCHES
      DO 47 J=1,N1
      IX=ICON1(J)
      IF (IX.LT.10000) GO TO 45
      IX=IX-10000
      IF (IX.GT.M1) GO TO 46
45    IX=ICON2(J)
      IF (IX.LT.10000) GO TO 47
      IX=IX-10000
      IF (IX.LT.M2) GO TO 47
46    IF (ICONX(J).NE.0) GO TO 47
      NSCON=NSCON+1
      ISCON(NSCON)=J
      ICONX(J)=NSCON
47    CONTINUE
48    CONTINUE
      RETURN
49    WRITE(3,53)  IX
      STOP
!
50    FORMAT (//,9X,27H- MULTIPLE WIRE JUNCTIONS -,/,1X,8HJUNCTION,4X,36
     1HSEGMENTS  (- FOR END 1, + FOR END 2))
51    FORMAT (1X,I5,5X,20I5,/,(11X,20I5))
52    FORMAT (2X,4HNONE)
53    FORMAT (47H CONNECT - SEGMENT CONNECTION ERROR FOR SEGMENT,I5)
54    FORMAT (/,3X,23HGROUND PLANE SPECIFIED.)
55    FORMAT (/,3X,46HWHERE WIRE ENDS TOUCH GROUND, CURRENT WILL BE ,38H
     1INTERPOLATED TO IMAGE IN GROUND PLANE.,/)
56    FORMAT (30H GEOMETRY DATA ERROR-- SEGMENT,I5,21H EXTENDS BELOW GRO
     1UND)
57    FORMAT (29H GEOMETRY DATA ERROR--SEGMENT,I5,16H LIES IN GROUND ,6H
     1PLANE.)
58    FORMAT (/,3X,20HTOTAL SEGMENTS USED=,I5,5X,12HNO. SEG. IN ,17HA SY
     1MMETRIC CELL=,I5,5X,14HSYMMETRY FLAG=,I3)
59    FORMAT (14H STRUCTURE HAS,I4,25H FOLD ROTATIONAL SYMMETRY,/)
60    FORMAT (14H STRUCTURE HAS,I2,19H PLANES OF SYMMETRY,/)
61    FORMAT (3X,19HTOTAL PATCHES USED=,I5,6X,32HNO. PATCHES IN A SYMMET
     1RIC CELL=,I5)
62    FORMAT (' ERROR - NO. NEW SEGMENTS CONNECTED TO N.G.F. SEGMENTS ',
     &'OR PATCHES EXCEEDS LIMIT OF',I5)
      END


!----------------------------------------------------------------------------

      SUBROUTINE COUPLE (CUR,WLAM)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'					! av07
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     COUPLE COMPUTES THE MAXIMUM COUPLING BETWEEN PAIRS OF SEGMENTS.
!
      COMPLEX*16 Y11A,Y12A,CUR,Y11,Y12,Y22,YL,YIN,ZL,ZIN,RHO,VQD,VSANT
     1,VQDS
      COMMON/YPARM/Y11A(5),Y12A(20),NCOUP,ICOUP,NCTAG(5),NCSEG(5)

      COMMON /VSORC/ VQD(nsmax),VSANT(nsmax),VQDS(nsmax),IVQD(nsmax),
     &ISANT(nsmax),IQDS(nsmax),NVQD,NSANT,NQDS			! av07

      DIMENSION CUR(1)
      IF (NSANT.NE.1.OR.NVQD.NE.0) RETURN
      J=ISEGNO(NCTAG(ICOUP+1),NCSEG(ICOUP+1))
      IF (J.NE.ISANT(1)) RETURN
      ICOUP=ICOUP+1
      ZIN=VSANT(1)
      Y11A(ICOUP)=CUR(J)*WLAM/ZIN
      L1=(ICOUP-1)*(NCOUP-1)
      DO 1 I=1,NCOUP
      IF (I.EQ.ICOUP) GO TO 1
      K=ISEGNO(NCTAG(I),NCSEG(I))
      L1=L1+1
      Y12A(L1)=CUR(K)*WLAM/ZIN
1     CONTINUE
      IF (ICOUP.LT.NCOUP) RETURN
      WRITE(3,6)
      NPM1=NCOUP-1
      DO 5 I=1,NPM1
      ITT1=NCTAG(I)
      ITS1=NCSEG(I)
      ISG1=ISEGNO(ITT1,ITS1)
      L1=I+1
      DO 5 J=L1,NCOUP
      ITT2=NCTAG(J)
      ITS2=NCSEG(J)
      ISG2=ISEGNO(ITT2,ITS2)
      J1=J+(I-1)*NPM1-1
      J2=I+(J-1)*NPM1
      Y11=Y11A(I)
      Y22=Y11A(J)
      Y12=.5*(Y12A(J1)+Y12A(J2))
      YIN=Y12*Y12
      DBC=ABS(YIN)
      C=DBC/(2.*DREAL(Y11)*DREAL(Y22)-DREAL(YIN))
      IF (C.LT.0..OR.C.GT.1.) GO TO 4
      IF (C.LT..01) GO TO 2
      GMAX=(1.-SQRT(1.-C*C))/C
      GO TO 3
2     GMAX=.5*(C+.25*C*C*C)
3     RHO=GMAX*DCONJG(YIN)/DBC
      YL=((1.-RHO)/(1.+RHO)+1.)*DREAL(Y22)-Y22
      ZL=1./YL
      YIN=Y11-YIN/(Y22+YL)
      ZIN=1./YIN
      DBC=DB10(GMAX)
      WRITE(3,7)  ITT1,ITS1,ISG1,ITT2,ITS2,ISG2,DBC,ZL,ZIN
      GO TO 5
4     WRITE(3,8)  ITT1,ITS1,ISG1,ITT2,ITS2,ISG2,C
5     CONTINUE
      RETURN
!
6     FORMAT (///,36X,26H- - - ISOLATION DATA - - -,//,6X,24H- - COUPLIN
     1G BETWEEN - -,8X,7HMAXIMUM,15X,32H- - - FOR MAXIMUM COUPLING - - -
     2,/,12X,4HSEG.,14X,4HSEG.,3X,8HCOUPLING,4X,25HLOAD IMPEDANCE (2ND S
     3EG.),7X,15HINPUT IMPEDANCE,/,2X,8HTAG/SEG.,3X,3HNO.,4X,8HTAG/SEG.,
     43X,3HNO.,6X,4H(DB),8X,4HREAL,9X,5HIMAG.,9X,4HREAL,9X,5HIMAG.)
7     FORMAT (2(1X,I4,1X,I4,1X,I5,2X),F9.3,2X,1P,2(2X,E12.5,1X,E12.5))
8     FORMAT (2(1X,I4,1X,I4,1X,I5,2X),45H**ERROR** COUPLING IS NOT BETWE
     1EN 0 AND 1. (=,1P,E12.5,1H))
      END
!----------------------------------------------------------------------------

      SUBROUTINE DATAGN
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     DATAGN IS THE MAIN ROUTINE FOR INPUT OF GEOMETRY DATA.
!
!***
      CHARACTER*2 GM,ATST
!***
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
!***
      COMMON /PLOT/ IPLP1,IPLP2,IPLP3,IPLP4
!***
      DIMENSION X2(1), Y2(1), Z2(1), T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y
     1(1), T2Z(1), ATST(13), IFX(2), IFY(2), IFZ(2), CAB(1), SAB(1), IPT
     2(4)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG), (X2,SI), (Y2,ALP), (Z2,BET), (CAB,ALP), (SAB,BET)
!***
      DATA ATST/'GW','GX','GR','GS','GE','GM','SP','SM','GF','GA','SC',
     1'GC','GH'/
!***
      DATA IFX/1H ,1HX/,IFY/1H ,1HY/,IFZ/1H ,1HZ/
      DATA TA/0.01745329252D+0/,TD/57.29577951D+0/,IPT/1HP,1HR,1HT,1HQ/
      IPSYM=0
      NWIRE=0
      N=0
      NP=0
      M=0
      MP=0
      N1=0
      N2=1
      M1=0
      M2=1
      ISCT=0
      IPHD=0
!
!     READ GEOMETRY DATA CARD AND BRANCH TO SECTION FOR OPERATION
!     REQUESTED
!
1     CALL READGM(2,GM,ITG,NS,XW1,YW1,ZW1,XW2,YW2,ZW2,RAD)
      IF (N+M.GT.LD) GO TO 37
      IF (GM.EQ.ATST(9)) GO TO 27
      IF (IPHD.EQ.1) GO TO 2
      WRITE(3,40)
      WRITE(3,41)
      IPHD=1
2     IF (GM.EQ.ATST(11)) GO TO 10
      ISCT=0
      IF (GM.EQ.ATST(1)) GO TO 3
      IF (GM.EQ.ATST(2)) GO TO 18
      IF (GM.EQ.ATST(3)) GO TO 19
      IF (GM.EQ.ATST(4)) GO TO 21
      IF (GM.EQ.ATST(7)) GO TO 9
      IF (GM.EQ.ATST(8)) GO TO 13
      IF (GM.EQ.ATST(5)) GO TO 29
      IF (GM.EQ.ATST(6)) GO TO 26
      IF (GM.EQ.ATST(10)) GO TO 8
!***
      IF (GM.EQ.ATST(13)) GO TO 123
!***
      GO TO 36
!
!     GENERATE SEGMENT DATA FOR STRAIGHT WIRE.
!
3     NWIRE=NWIRE+1
      I1=N+1
      I2=N+NS
      WRITE(3,43)  NWIRE,XW1,YW1,ZW1,XW2,YW2,ZW2,RAD,NS,I1,I2,ITG
      IF (RAD.EQ.0) GO TO 4
      XS1=1.
      YS1=1.
      GO TO 7
4     CALL READGM(2,GM,IX,IY,XS1,YS1,ZS1,DUMMY,DUMMY,DUMMY,DUMMY)
!***
      IF (GM.EQ.ATST(12)) GO TO 6
5     WRITE(3,48)
      STOP
6     WRITE(3,61)  XS1,YS1,ZS1
      IF (YS1.EQ.0.OR.ZS1.EQ.0) GO TO 5
      RAD=YS1
      YS1=(ZS1/YS1)**(1./(NS-1.))
7     CALL WIRE (XW1,YW1,ZW1,XW2,YW2,ZW2,RAD,XS1,YS1,NS,ITG)
      GO TO 1
!
!     GENERATE SEGMENT DATA FOR WIRE ARC
!
8     NWIRE=NWIRE+1
      I1=N+1
      I2=N+NS
      WRITE(3,38)  NWIRE,XW1,YW1,ZW1,XW2,NS,I1,I2,ITG
      CALL ARC (ITG,NS,XW1,YW1,ZW1,XW2)
      GO TO 1
!***
!
!     GENERATE HELIX
!
123   NWIRE=NWIRE+1
      I1=N+1
      I2=N+NS
      WRITE(3,124) XW1,YW1,NWIRE,ZW1,XW2,YW2,ZW2,RAD,NS,I1,I2,ITG
      CALL HELIX(XW1,YW1,ZW1,XW2,YW2,ZW2,RAD,NS,ITG)
      GO TO 1
!
124   FORMAT(5X,'HELIX STRUCTURE-   AXIAL SPACING BETWEEN TURNS =',F8.3,
     1' TOTAL AXIAL LENGTH =',F8.3/1X,I5,2X,'RADIUS OF HELIX =',4(2X,
     2F8.3),7X,F11.5,I8,4X,I5,1X,I5,3X,I5)
!***
!
!     GENERATE SINGLE NEW PATCH
!
9     I1=M+1
      NS=NS+1
      IF (ITG.NE.0) GO TO 17
      WRITE(3,51)  I1,IPT(NS),XW1,YW1,ZW1,XW2,YW2,ZW2
      IF (NS.EQ.2.OR.NS.EQ.4) ISCT=1
      IF (NS.GT.1) GO TO 14
      XW2=XW2*TA
      YW2=YW2*TA
      GO TO 16
10    IF (ISCT.EQ.0) GO TO 17
      I1=M+1
      NS=NS+1
      IF (ITG.NE.0) GO TO 17
      IF (NS.NE.2.AND.NS.NE.4) GO TO 17
      XS1=X4
      YS1=Y4
      ZS1=Z4
      XS2=X3
      YS2=Y3
      ZS2=Z3
      X3=XW1
      Y3=YW1
      Z3=ZW1
      IF (NS.NE.4) GO TO 11
      X4=XW2
      Y4=YW2
      Z4=ZW2
11    XW1=XS1
      YW1=YS1
      ZW1=ZS1
      XW2=XS2
      YW2=YS2
      ZW2=ZS2
      IF (NS.EQ.4) GO TO 12
      X4=XW1+X3-XW2
      Y4=YW1+Y3-YW2
      Z4=ZW1+Z3-ZW2
12    WRITE(3,51)  I1,IPT(NS),XW1,YW1,ZW1,XW2,YW2,ZW2
      WRITE(3,39)  X3,Y3,Z3,X4,Y4,Z4
      GO TO 16
!
!     GENERATE MULTIPLE-PATCH SURFACE
!
13    I1=M+1
      WRITE(3,59)  I1,IPT(2),XW1,YW1,ZW1,XW2,YW2,ZW2,ITG,NS
      IF (ITG.LT.1.OR.NS.LT.1) GO TO 17
14    CALL READGM(2,GM,IX,IY,X3,Y3,Z3,X4,Y4,Z4,DUMMY)
      IF (NS.NE.2.AND.ITG.LT.1) GO TO 15
      X4=XW1+X3-XW2
      Y4=YW1+Y3-YW2
      Z4=ZW1+Z3-ZW2
15    WRITE(3,39)  X3,Y3,Z3,X4,Y4,Z4
      IF (GM.NE.ATST(11)) GO TO 17
16    CALL PATCH (ITG,NS,XW1,YW1,ZW1,XW2,YW2,ZW2,X3,Y3,Z3,X4,Y4,Z4)
      GO TO 1
17    WRITE(3,60)
      STOP
!
!     REFLECT STRUCTURE ALONG X,Y, OR Z AXES OR ROTATE TO FORM CYLINDER.
!
18    IY=NS/10
      IZ=NS-IY*10
      IX=IY/10
      IY=IY-IX*10
      IF (IX.NE.0) IX=1
      IF (IY.NE.0) IY=1
      IF (IZ.NE.0) IZ=1
      WRITE(3,44)  IFX(IX+1),IFY(IY+1),IFZ(IZ+1),ITG
      GO TO 20
19    WRITE(3,45)  NS,ITG
      IX=-1
20    CALL REFLC (IX,IY,IZ,ITG,NS)
      GO TO 1
!
!     SCALE STRUCTURE DIMENSIONS BY FACTOR XW1.
!
21    IF (N.LT.N2) GO TO 23
      DO 22 I=N2,N
      X(I)=X(I)*XW1
      Y(I)=Y(I)*XW1
      Z(I)=Z(I)*XW1
      X2(I)=X2(I)*XW1
      Y2(I)=Y2(I)*XW1
      Z2(I)=Z2(I)*XW1
22    BI(I)=BI(I)*XW1
23    IF (M.LT.M2) GO TO 25
      YW1=XW1*XW1
      IX=LD+1-M
      IY=LD-M1
      DO 24 I=IX,IY
      X(I)=X(I)*XW1
      Y(I)=Y(I)*XW1
      Z(I)=Z(I)*XW1
24    BI(I)=BI(I)*YW1
25    WRITE(3,46)  XW1
      GO TO 1
!
!     MOVE STRUCTURE OR REPRODUCE ORIGINAL STRUCTURE IN NEW POSITIONS.
!
26    WRITE(3,47)  ITG,NS,XW1,YW1,ZW1,XW2,YW2,ZW2,RAD
      XW1=XW1*TA
      YW1=YW1*TA
      ZW1=ZW1*TA
      CALL MOVE (XW1,YW1,ZW1,XW2,YW2,ZW2,INT(RAD+.5),NS,ITG)
      GO TO 1
!
!     READ NUMERICAL GREEN'S FUNCTION TAPE
!
27    IF (N+M.EQ.0) GO TO 28
      WRITE(3,52)
      STOP
28    CALL GFIL (ITG)
      NPSAV=NP
      MPSAV=MP
      IPSAV=IPSYM
      GO TO 1
!
!     TERMINATE STRUCTURE GEOMETRY INPUT.
!
!***
29    IF(NS.EQ.0) GO TO 290
      IPLP1=1
      IPLP2=1
290   IX=N1+M1
!***
      IF (IX.EQ.0) GO TO 30
      NP=N
      MP=M
      IPSYM=0
30    CALL CONECT (ITG)
      IF (IX.EQ.0) GO TO 31
      NP=NPSAV
      MP=MPSAV
      IPSYM=IPSAV
31    IF (N+M.GT.LD) GO TO 37
      IF (N.EQ.0) GO TO 33
      WRITE(3,53)
      WRITE(3,54)
      DO 32 I=1,N
      XW1=X2(I)-X(I)
      YW1=Y2(I)-Y(I)
      ZW1=Z2(I)-Z(I)
      X(I)=(X(I)+X2(I))*.5
      Y(I)=(Y(I)+Y2(I))*.5
      Z(I)=(Z(I)+Z2(I))*.5
      XW2=XW1*XW1+YW1*YW1+ZW1*ZW1
      YW2=SQRT(XW2)
      YW2=(XW2/YW2+YW2)*.5
      SI(I)=YW2
      CAB(I)=XW1/YW2
      SAB(I)=YW1/YW2
      XW2=ZW1/YW2
      IF (XW2.GT.1.) XW2=1.
      IF (XW2.LT.-1.) XW2=-1.
      SALP(I)=XW2
      XW2=ASIN(XW2)*TD
      YW2=ATGN2(YW1,XW1)*TD
      WRITE(3,55) I,X(I),Y(I),Z(I),SI(I),XW2,YW2,BI(I),ICON1(I),I,
     1ICON2(I),ITAG(I)
!***
      IF(IPLP1.NE.1) GO TO 320
      WRITE(8,*)X(I),Y(I),Z(I),SI(I),XW2,YW2,BI(I),ICON1(I),I,ICON2(I)
320   CONTINUE
!***
      IF (SI(I).GT.1.D-20.AND.BI(I).GT.0.) GO TO 32
      WRITE(3,56)
      STOP
32    CONTINUE
33    IF (M.EQ.0) GO TO 35
      WRITE(3,57)
      J=LD+1
      DO 34 I=1,M
      J=J-1
      XW1=(T1Y(J)*T2Z(J)-T1Z(J)*T2Y(J))*SALP(J)
      YW1=(T1Z(J)*T2X(J)-T1X(J)*T2Z(J))*SALP(J)
      ZW1=(T1X(J)*T2Y(J)-T1Y(J)*T2X(J))*SALP(J)
      WRITE(3,58) I,X(J),Y(J),Z(J),XW1,YW1,ZW1,BI(J),T1X(J),T1Y(J),
     1T1Z(J),T2X(J),T2Y(J),T2Z(J)
34    CONTINUE
35    RETURN
36    WRITE(3,48)
      WRITE(3,49)  GM,ITG,NS,XW1,YW1,ZW1,XW2,YW2,ZW2,RAD
      STOP
37    WRITE(3,50)
      STOP
!
38    FORMAT (1X,I5,2X,12HARC RADIUS =,F9.5,2X,4HFROM,F8.3,3H TO,F8.3,8H
     1 DEGREES,11X,F11.5,2X,I5,4X,I5,1X,I5,3X,I5)
39    FORMAT (6X,3F11.5,1X,3F11.5)
40    FORMAT (////,33X,35H- - - STRUCTURE SPECIFICATION - - -,//,37X,28H
     1COORDINATES MUST BE INPUT IN,/,37X,29HMETERS OR BE SCALED TO METER
     2S,/,37X,31HBEFORE STRUCTURE INPUT IS ENDED,//)
41    FORMAT (2X,4HWIRE,79X,6HNO. OF,4X,5HFIRST,2X,4HLAST,5X,3HTAG,/,2X,
     13HNO.,8X,2HX1,9X,2HY1,9X,2HZ1,10X,2HX2,9X,2HY2,9X,2HZ2,6X,6HRADIUS
     2,3X,4HSEG.,5X,4HSEG.,3X,4HSEG.,5X,3HNO.)
42    FORMAT (A2,I3,I5,7F10.5)
43    FORMAT (1X,I5,3F11.5,1X,4F11.5,2X,I5,4X,I5,1X,I5,3X,I5)
44    FORMAT (6X,34HSTRUCTURE REFLECTED ALONG THE AXES,3(1X,A1),22H.  TA
     1GS INCREMENTED BY,I5)
45    FORMAT (6X,30HSTRUCTURE ROTATED ABOUT Z-AXIS,I3,30H TIMES.  LABELS
     1 INCREMENTED BY,I5)
46    FORMAT (6X,26HSTRUCTURE SCALED BY FACTOR,F10.5)
47    FORMAT (6X,49HTHE STRUCTURE HAS BEEN MOVED, MOVE DATA CARD IS -/6X
     1,I3,I5,7F10.5)
48    FORMAT (25H GEOMETRY DATA CARD ERROR)
49    FORMAT (1X,A2,I3,I5,7F10.5)
50    FORMAT (69H NUMBER OF WIRE SEGMENTS AND SURFACE PATCHES EXCEEDS DI
     1MENSION LIMIT.)
51    FORMAT (1X,I5,A1,F10.5,2F11.5,1X,3F11.5)
52    FORMAT (44H ERROR - GF MUST BE FIRST GEOMETRY DATA CARD)
53    FORMAT (////33X,33H- - - - SEGMENTATION DATA - - - -,//,40X,21HCOO
     1RDINATES IN METERS,//,25X,50HI+ AND I- INDICATE THE SEGMENTS BEFOR
     2E AND AFTER I,//)
54    FORMAT (2X,4HSEG.,3X,26HCOORDINATES OF SEG. CENTER,5X,4HSEG.,5X,18
     1HORIENTATION ANGLES,4X,4HWIRE,4X,15HCONNECTION DATA,3X,3HTAG,/,2X,
     23HNO.,7X,1HX,9X,1HY,9X,1HZ,7X,6HLENGTH,5X,5HALPHA,5X,4HBETA,6X,6HR
     3ADIUS,4X,2HI-,3X,1HI,4X,2HI+,4X,3HNO.)
55    FORMAT (1X,I5,4F10.5,1X,3F10.5,1X,3I5,2X,I5)
56    FORMAT (19H SEGMENT DATA ERROR)
57    FORMAT (////,44X,30H- - - SURFACE PATCH DATA - - -,//,49X,21HCOORD
     1INATES IN METERS,//,1X,5HPATCH,5X,22HCOORD. OF PATCH CENTER,7X,18H
     2UNIT NORMAL VECTOR,6X,5HPATCH,12X,34HCOMPONENTS OF UNIT TANGENT VE
     3CTORS,/,2X,3HNO.,6X,1HX,9X,1HY,9X,1HZ,9X,1HX,7X,1HY,7X,1HZ,7X,4HAR
     4EA,7X,2HX1,6X,2HY1,6X,2HZ1,7X,2HX2,6X,2HY2,6X,2HZ2)
58    FORMAT (1X,I4,3F10.5,1X,3F8.4,F10.5,1X,3F8.4,1X,3F8.4)
59    FORMAT (1X,I5,A1,F10.5,2F11.5,1X,3F11.5,5X,9HSURFACE -,I4,3H BY,I3
     1,8H PATCHES)
60    FORMAT (17H PATCH DATA ERROR)
61    FORMAT (9X,43HABOVE WIRE IS TAPERED.  SEG. LENGTH RATIO =,F9.5,/,3
     13X,11HRADIUS FROM,F9.5,3H TO,F9.5)
      END
      FUNCTION DB10 (X)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     FUNCTION DB-- RETURNS DB FOR MAGNITUDE (FIELD) OR MAG**2 (POWER) I
!
      F=10.
      GO TO 1
      ENTRY DB20(X)
      F=20.
1     IF (X.LT.1.D-20) GO TO 2
      DB10=F*LOG10(X)
      RETURN
2     DB10=-999.99
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE EFLD (XI,YI,ZI,AI,IJ)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     COMPUTE NEAR E FIELDS OF A SEGMENT WITH SINE, COSINE, AND
!     CONSTANT CURRENTS.  GROUND EFFECT INCLUDED.
!
      COMPLEX*16 TXK,TYK,TZK,TXS,TYS,TZS,TXC,TYC,TZC,EXK,EYK,EZK,EXS,EYS
     1,EZS,EXC,EYC,EZC,EPX,EPY,ZRATI,REFS,REFPS,ZRSIN,ZRATX,T1,ZSCRN
     2,ZRATI2,TEZS,TERS,TEZC,TERC,TEZK,TERK,EGND,FRATI
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      COMMON /INCOM/ XO,YO,ZO,SN,XSN,YSN,ISNOR
      DIMENSION EGND(9)
      EQUIVALENCE (EGND(1),TXK), (EGND(2),TYK), (EGND(3),TZK), (EGND(4),
     1TXS), (EGND(5),TYS), (EGND(6),TZS), (EGND(7),TXC), (EGND(8),TYC),
     2(EGND(9),TZC)
      DATA ETA/376.73/,PI/3.141592654D+0/,TP/6.283185308D+0/
      XIJ=XI-XJ
      YIJ=YI-YJ
      IJX=IJ
      RFL=-1.
      DO 12 IP=1,KSYMP
      IF (IP.EQ.2) IJX=1
      RFL=-RFL
      SALPR=SALPJ*RFL
      ZIJ=ZI-RFL*ZJ
      ZP=XIJ*CABJ+YIJ*SABJ+ZIJ*SALPR
      RHOX=XIJ-CABJ*ZP
      RHOY=YIJ-SABJ*ZP
      RHOZ=ZIJ-SALPR*ZP
      RH=SQRT(RHOX*RHOX+RHOY*RHOY+RHOZ*RHOZ+AI*AI)
      IF (RH.GT.1.D-10) GO TO 1
      RHOX=0.
      RHOY=0.
      RHOZ=0.
      GO TO 2
1     RHOX=RHOX/RH
      RHOY=RHOY/RH
      RHOZ=RHOZ/RH
2     R=SQRT(ZP*ZP+RH*RH)
      IF (R.LT.RKH) GO TO 3
!
!     LUMPED CURRENT ELEMENT APPROX. FOR LARGE SEPARATIONS
!
      RMAG=TP*R
      CTH=ZP/R
      PX=RH/R
      TXK=DCMPLX(COS(RMAG),-SIN(RMAG))
      PY=TP*R*R
      TYK=ETA*CTH*TXK*DCMPLX(1.D+0,-1.D+0/RMAG)/PY
      TZK=ETA*PX*TXK*DCMPLX(1.D+0,RMAG-1.D+0/RMAG)/(2.*PY)
      TEZK=TYK*CTH-TZK*PX
      TERK=TYK*PX+TZK*CTH
      RMAG=SIN(PI*S)/PI
      TEZC=TEZK*RMAG
      TERC=TERK*RMAG
      TEZK=TEZK*S
      TERK=TERK*S
      TXS=(0.,0.)
      TYS=(0.,0.)
      TZS=(0.,0.)
      GO TO 6
3     IF (IEXK.EQ.1) GO TO 4
!
!     EKSC FOR THIN WIRE APPROX. OR EKSCX FOR EXTENDED T.W. APPROX.
!
      CALL EKSC (S,ZP,RH,TP,IJX,TEZS,TERS,TEZC,TERC,TEZK,TERK)
      GO TO 5
4     CALL EKSCX (B,S,ZP,RH,TP,IJX,IND1,IND2,TEZS,TERS,TEZC,TERC,TEZK,TE
     1RK)
5     TXS=TEZS*CABJ+TERS*RHOX
      TYS=TEZS*SABJ+TERS*RHOY
      TZS=TEZS*SALPR+TERS*RHOZ
6     TXK=TEZK*CABJ+TERK*RHOX
      TYK=TEZK*SABJ+TERK*RHOY
      TZK=TEZK*SALPR+TERK*RHOZ
      TXC=TEZC*CABJ+TERC*RHOX
      TYC=TEZC*SABJ+TERC*RHOY
      TZC=TEZC*SALPR+TERC*RHOZ
      IF (IP.NE.2) GO TO 11
      IF (IPERF.GT.0) GO TO 10
      ZRATX=ZRATI
      RMAG=R
      XYMAG=SQRT(XIJ*XIJ+YIJ*YIJ)
!
!     SET PARAMETERS FOR RADIAL WIRE GROUND SCREEN.
!
      IF (NRADL.EQ.0) GO TO 7
      XSPEC=(XI*ZJ+ZI*XJ)/(ZI+ZJ)
      YSPEC=(YI*ZJ+ZI*YJ)/(ZI+ZJ)
      RHOSPC=SQRT(XSPEC*XSPEC+YSPEC*YSPEC+T2*T2)
      IF (RHOSPC.GT.SCRWL) GO TO 7
      ZSCRN=T1*RHOSPC*LOG(RHOSPC/T2)
      ZRATX=(ZSCRN*ZRATI)/(ETA*ZRATI+ZSCRN)
7     IF (XYMAG.GT.1.D-6) GO TO 8
!
!     CALCULATION OF REFLECTION COEFFICIENTS WHEN GROUND IS SPECIFIED.
!
      PX=0.
      PY=0.
      CTH=1.
      ZRSIN=(1.,0.)
      GO TO 9
8     PX=-YIJ/XYMAG
      PY=XIJ/XYMAG
      CTH=ZIJ/RMAG
      ZRSIN=SQRT(1.-ZRATX*ZRATX*(1.-CTH*CTH))
9     REFS=(CTH-ZRATX*ZRSIN)/(CTH+ZRATX*ZRSIN)
      REFPS=-(ZRATX*CTH-ZRSIN)/(ZRATX*CTH+ZRSIN)
      REFPS=REFPS-REFS
      EPY=PX*TXK+PY*TYK
      EPX=PX*EPY
      EPY=PY*EPY
      TXK=REFS*TXK+REFPS*EPX
      TYK=REFS*TYK+REFPS*EPY
      TZK=REFS*TZK
      EPY=PX*TXS+PY*TYS
      EPX=PX*EPY
      EPY=PY*EPY
      TXS=REFS*TXS+REFPS*EPX
      TYS=REFS*TYS+REFPS*EPY
      TZS=REFS*TZS
      EPY=PX*TXC+PY*TYC
      EPX=PX*EPY
      EPY=PY*EPY
      TXC=REFS*TXC+REFPS*EPX
      TYC=REFS*TYC+REFPS*EPY
      TZC=REFS*TZC
10    EXK=EXK-TXK*FRATI
      EYK=EYK-TYK*FRATI
      EZK=EZK-TZK*FRATI
      EXS=EXS-TXS*FRATI
      EYS=EYS-TYS*FRATI
      EZS=EZS-TZS*FRATI
      EXC=EXC-TXC*FRATI
      EYC=EYC-TYC*FRATI
      EZC=EZC-TZC*FRATI
      GO TO 12
11    EXK=TXK
      EYK=TYK
      EZK=TZK
      EXS=TXS
      EYS=TYS
      EZS=TZS
      EXC=TXC
      EYC=TYC
      EZC=TZC
12    CONTINUE
      IF (IPERF.EQ.2) GO TO 13
      RETURN
!
!     FIELD DUE TO GROUND USING SOMMERFELD/NORTON
!
13    SN=SQRT(CABJ*CABJ+SABJ*SABJ)
      IF (SN.LT.1.D-5) GO TO 14
      XSN=CABJ/SN
      YSN=SABJ/SN
      GO TO 15
14    SN=0.
      XSN=1.
      YSN=0.
!
!     DISPLACE OBSERVATION POINT FOR THIN WIRE APPROXIMATION
!
15    ZIJ=ZI+ZJ
      SALPR=-SALPJ
      RHOX=SABJ*ZIJ-SALPR*YIJ
      RHOY=SALPR*XIJ-CABJ*ZIJ
      RHOZ=CABJ*YIJ-SABJ*XIJ
      RH=RHOX*RHOX+RHOY*RHOY+RHOZ*RHOZ
      IF (RH.GT.1.D-10) GO TO 16
      XO=XI-AI*YSN
      YO=YI+AI*XSN
      ZO=ZI
      GO TO 17
16    RH=AI/SQRT(RH)
      IF (RHOZ.LT.0.) RH=-RH
      XO=XI+RH*RHOX
      YO=YI+RH*RHOY
      ZO=ZI+RH*RHOZ
17    R=XIJ*XIJ+YIJ*YIJ+ZIJ*ZIJ
      IF (R.GT..95) GO TO 18
!
!     FIELD FROM INTERPOLATION IS INTEGRATED OVER SEGMENT
!
      ISNOR=1
      DMIN=EXK*DCONJG(EXK)+EYK*DCONJG(EYK)+EZK*DCONJG(EZK)
      DMIN=.01*SQRT(DMIN)
      SHAF=.5*S
      CALL ROM2 (-SHAF,SHAF,EGND,DMIN)
      GO TO 19
!
!     NORTON FIELD EQUATIONS AND LUMPED CURRENT ELEMENT APPROXIMATION
!
18    ISNOR=2
      CALL SFLDS (0.D0,EGND)
      GO TO 22
19    ZP=XIJ*CABJ+YIJ*SABJ+ZIJ*SALPR
      RH=R-ZP*ZP
      IF (RH.GT.1.D-10) GO TO 20
      DMIN=0.
      GO TO 21
20    DMIN=SQRT(RH/(RH+AI*AI))
21    IF (DMIN.GT..95) GO TO 22
      PX=1.-DMIN
      TERK=(TXK*CABJ+TYK*SABJ+TZK*SALPR)*PX
      TXK=DMIN*TXK+TERK*CABJ
      TYK=DMIN*TYK+TERK*SABJ
      TZK=DMIN*TZK+TERK*SALPR
      TERS=(TXS*CABJ+TYS*SABJ+TZS*SALPR)*PX
      TXS=DMIN*TXS+TERS*CABJ
      TYS=DMIN*TYS+TERS*SABJ
      TZS=DMIN*TZS+TERS*SALPR
      TERC=(TXC*CABJ+TYC*SABJ+TZC*SALPR)*PX
      TXC=DMIN*TXC+TERC*CABJ
      TYC=DMIN*TYC+TERC*SABJ
      TZC=DMIN*TZC+TERC*SALPR
22    EXK=EXK+TXK
      EYK=EYK+TYK
      EZK=EZK+TZK
      EXS=EXS+TXS
      EYS=EYS+TYS
      EZS=EZS+TZS
      EXC=EXC+TXC
      EYC=EYC+TYC
      EZC=EZC+TZC
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE EKSC (S,Z,RH,XK,IJ,EZS,ERS,EZC,ERC,EZK,ERK)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     COMPUTE E FIELD OF SINE, COSINE, AND CONSTANT CURRENT FILAMENTS BY
!     THIN WIRE APPROXIMATION.
      COMPLEX*16 CON,GZ1,GZ2,GP1,GP2,GZP1,GZP2,EZS,ERS,EZC,ERC,EZK,ERK
      COMMON /TMI/ ZPK,RKB2,IJX
      DIMENSION CONX(2)
      EQUIVALENCE (CONX,CON)
      DATA CONX/0.,4.771341189D+0/
      IJX=IJ
      ZPK=XK*Z
      RHK=XK*RH
      RKB2=RHK*RHK
      SH=.5*S
      SHK=XK*SH
      SS=SIN(SHK)
      CS=COS(SHK)
      Z2=SH-Z
      Z1=-(SH+Z)
      CALL GX (Z1,RH,XK,GZ1,GP1)
      CALL GX (Z2,RH,XK,GZ2,GP2)
      GZP1=GP1*Z1
      GZP2=GP2*Z2
      EZS=CON*((GZ2-GZ1)*CS*XK-(GZP2+GZP1)*SS)
      EZC=-CON*((GZ2+GZ1)*SS*XK+(GZP2-GZP1)*CS)
      ERK=CON*(GP2-GP1)*RH
      CALL INTX (-SHK,SHK,RHK,IJ,CINT,SINT)
      EZK=-CON*(GZP2-GZP1+XK*XK*DCMPLX(CINT,-SINT))
      GZP1=GZP1*Z1
      GZP2=GZP2*Z2
      IF (RH.LT.1.D-10) GO TO 1
      ERS=-CON*((GZP2+GZP1+GZ2+GZ1)*SS-(Z2*GZ2-Z1*GZ1)*CS*XK)/RH
      ERC=-CON*((GZP2-GZP1+GZ2-GZ1)*CS+(Z2*GZ2+Z1*GZ1)*SS*XK)/RH
      RETURN
1     ERS=(0.,0.)
      ERC=(0.,0.)
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE EKSCX (BX,S,Z,RHX,XK,IJ,INX1,INX2,EZS,ERS,EZC,ERC,EZK,E
     1RK)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     COMPUTE E FIELD OF SINE, COSINE, AND CONSTANT CURRENT FILAMENTS BY
!     EXTENDED THIN WIRE APPROXIMATION.
      COMPLEX*16 CON,GZ1,GZ2,GZP1,GZP2,GR1,GR2,GRP1,GRP2,EZS,EZC,ERS,ERC
     1,GRK1,GRK2,EZK,ERK,GZZ1,GZZ2
      COMMON /TMI/ ZPK,RKB2,IJX
      DIMENSION CONX(2)
      EQUIVALENCE (CONX,CON)
      DATA CONX/0.,4.771341189D+0/
      IF (RHX.LT.BX) GO TO 1
      RH=RHX
      B=BX
      IRA=0
      GO TO 2
1     RH=BX
      B=RHX
      IRA=1
2     SH=.5*S
      IJX=IJ
      ZPK=XK*Z
      RHK=XK*RH
      RKB2=RHK*RHK
      SHK=XK*SH
      SS=SIN(SHK)
      CS=COS(SHK)
      Z2=SH-Z
      Z1=-(SH+Z)
      A2=B*B
      IF (INX1.EQ.2) GO TO 3
      CALL GXX (Z1,RH,B,A2,XK,IRA,GZ1,GZP1,GR1,GRP1,GRK1,GZZ1)
      GO TO 4
3     CALL GX (Z1,RHX,XK,GZ1,GRK1)
      GZP1=GRK1*Z1
      GR1=GZ1/RHX
      GRP1=GZP1/RHX
      GRK1=GRK1*RHX
      GZZ1=(0.,0.)
4     IF (INX2.EQ.2) GO TO 5
      CALL GXX (Z2,RH,B,A2,XK,IRA,GZ2,GZP2,GR2,GRP2,GRK2,GZZ2)
      GO TO 6
5     CALL GX (Z2,RHX,XK,GZ2,GRK2)
      GZP2=GRK2*Z2
      GR2=GZ2/RHX
      GRP2=GZP2/RHX
      GRK2=GRK2*RHX
      GZZ2=(0.,0.)
6     EZS=CON*((GZ2-GZ1)*CS*XK-(GZP2+GZP1)*SS)
      EZC=-CON*((GZ2+GZ1)*SS*XK+(GZP2-GZP1)*CS)
      ERS=-CON*((Z2*GRP2+Z1*GRP1+GR2+GR1)*SS-(Z2*GR2-Z1*GR1)*CS*XK)
      ERC=-CON*((Z2*GRP2-Z1*GRP1+GR2-GR1)*CS+(Z2*GR2+Z1*GR1)*SS*XK)
      ERK=CON*(GRK2-GRK1)
      CALL INTX (-SHK,SHK,RHK,IJ,CINT,SINT)
      BK=B*XK
      BK2=BK*BK*.25
      EZK=-CON*(GZP2-GZP1+XK*XK*(1.-BK2)*DCMPLX(CINT,-SINT)-BK2*(GZZ2-
     1GZZ1))
      RETURN
      END

!----------------------------------------------------------------------------

      SUBROUTINE ETMNS (P1,P2,P3,P4,P5,P6,IPR,E)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     ETMNS FILLS THE ARRAY E WITH THE NEGATIVE OF THE ELECTRIC FIELD
!     INCIDENT ON THE STRUCTURE.  E IS THE RIGHT HAND SIDE OF THE MATRIX
!     EQUATION.
!
      COMPLEX*16 E,CX,CY,CZ,VSANT,ER,ET,EZH,ERH,VQD,VQDS,ZRATI
     1,ZRATI2,RRV,RRH,T1,TT1,TT2,FRATI
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)

      COMMON /VSORC/ VQD(nsmax),VSANT(nsmax),VQDS(nsmax),IVQD(nsmax),
     &ISANT(nsmax),IQDS(nsmax),NVQD,NSANT,NQDS			! av07

      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      DIMENSION CAB(1), SAB(1), E(2*MAXSEG)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1)
      EQUIVALENCE (CAB,ALP), (SAB,BET)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG)
      DATA TP/6.283185308D+0/,RETA/2.654420938D-3/
      NEQ=N+2*M
      NQDS=0
      IF (IPR.GT.0.AND.IPR.NE.5) GO TO 5
!
!     APPLIED FIELD OF VOLTAGE SOURCES FOR TRANSMITTING CASE
!
      DO 1 I=1,NEQ
1     E(I)=(0.,0.)
      IF (NSANT.EQ.0) GO TO 3
      DO 2 I=1,NSANT
      IS=ISANT(I)
2     E(IS)=-VSANT(I)/(SI(IS)*WLAM)
3     IF (NVQD.EQ.0) RETURN
      DO 4 I=1,NVQD
      IS=IVQD(I)
4     CALL QDSRC (IS,VQD(I),E)
      RETURN
5     IF (IPR.GT.3) GO TO 19
!
!     INCIDENT PLANE WAVE, LINEARLY POLARIZED.
!
      CTH=COS(P1)
      STH=SIN(P1)
      CPH=COS(P2)
      SPH=SIN(P2)
      CET=COS(P3)
      SET=SIN(P3)
      PX=CTH*CPH*CET-SPH*SET
      PY=CTH*SPH*CET+CPH*SET
      PZ=-STH*CET
      WX=-STH*CPH
      WY=-STH*SPH
      WZ=-CTH
      QX=WY*PZ-WZ*PY
      QY=WZ*PX-WX*PZ
      QZ=WX*PY-WY*PX
      IF (KSYMP.EQ.1) GO TO 7
      IF (IPERF.EQ.1) GO TO 6
      RRV=SQRT(1.-ZRATI*ZRATI*STH*STH)
      RRH=ZRATI*CTH
      RRH=(RRH-RRV)/(RRH+RRV)
      RRV=ZRATI*RRV
      RRV=-(CTH-RRV)/(CTH+RRV)
      GO TO 7
6     RRV=-(1.,0.)
      RRH=-(1.,0.)
7     IF (IPR.GT.1) GO TO 13
      IF (N.EQ.0) GO TO 10
      DO 8 I=1,N
      ARG=-TP*(WX*X(I)+WY*Y(I)+WZ*Z(I))
8     E(I)=-(PX*CAB(I)+PY*SAB(I)+PZ*SALP(I))*DCMPLX(COS(ARG),SIN(ARG))
      IF (KSYMP.EQ.1) GO TO 10
      TT1=(PY*CPH-PX*SPH)*(RRH-RRV)
      CX=RRV*PX-TT1*SPH
      CY=RRV*PY+TT1*CPH
      CZ=-RRV*PZ
      DO 9 I=1,N
      ARG=-TP*(WX*X(I)+WY*Y(I)-WZ*Z(I))
9     E(I)=E(I)-(CX*CAB(I)+CY*SAB(I)+CZ*SALP(I))*DCMPLX(COS(ARG),
     1SIN(ARG))
10    IF (M.EQ.0) RETURN
      I=LD+1
      I1=N-1
      DO 11 IS=1,M
      I=I-1
      I1=I1+2
      I2=I1+1
      ARG=-TP*(WX*X(I)+WY*Y(I)+WZ*Z(I))
      TT1=DCMPLX(COS(ARG),SIN(ARG))*SALP(I)*RETA
      E(I2)=(QX*T1X(I)+QY*T1Y(I)+QZ*T1Z(I))*TT1
11    E(I1)=(QX*T2X(I)+QY*T2Y(I)+QZ*T2Z(I))*TT1
      IF (KSYMP.EQ.1) RETURN
      TT1=(QY*CPH-QX*SPH)*(RRV-RRH)
      CX=-(RRH*QX-TT1*SPH)
      CY=-(RRH*QY+TT1*CPH)
      CZ=RRH*QZ
      I=LD+1
      I1=N-1
      DO 12 IS=1,M
      I=I-1
      I1=I1+2
      I2=I1+1
      ARG=-TP*(WX*X(I)+WY*Y(I)-WZ*Z(I))
      TT1=DCMPLX(COS(ARG),SIN(ARG))*SALP(I)*RETA
      E(I2)=E(I2)+(CX*T1X(I)+CY*T1Y(I)+CZ*T1Z(I))*TT1
12    E(I1)=E(I1)+(CX*T2X(I)+CY*T2Y(I)+CZ*T2Z(I))*TT1
      RETURN
!
!     INCIDENT PLANE WAVE, ELLIPTIC POLARIZATION.
!
13    TT1=-(0.,1.)*P6
      IF (IPR.EQ.3) TT1=-TT1
      IF (N.EQ.0) GO TO 16
      CX=PX+TT1*QX
      CY=PY+TT1*QY
      CZ=PZ+TT1*QZ
      DO 14 I=1,N
      ARG=-TP*(WX*X(I)+WY*Y(I)+WZ*Z(I))
14    E(I)=-(CX*CAB(I)+CY*SAB(I)+CZ*SALP(I))*DCMPLX(COS(ARG),SIN(ARG))
      IF (KSYMP.EQ.1) GO TO 16
      TT2=(CY*CPH-CX*SPH)*(RRH-RRV)
      CX=RRV*CX-TT2*SPH
      CY=RRV*CY+TT2*CPH
      CZ=-RRV*CZ
      DO 15 I=1,N
      ARG=-TP*(WX*X(I)+WY*Y(I)-WZ*Z(I))
15    E(I)=E(I)-(CX*CAB(I)+CY*SAB(I)+CZ*SALP(I))*DCMPLX(COS(ARG),
     1SIN(ARG))
16    IF (M.EQ.0) RETURN
      CX=QX-TT1*PX
      CY=QY-TT1*PY
      CZ=QZ-TT1*PZ
      I=LD+1
      I1=N-1
      DO 17 IS=1,M
      I=I-1
      I1=I1+2
      I2=I1+1
      ARG=-TP*(WX*X(I)+WY*Y(I)+WZ*Z(I))
      TT2=DCMPLX(COS(ARG),SIN(ARG))*SALP(I)*RETA
      E(I2)=(CX*T1X(I)+CY*T1Y(I)+CZ*T1Z(I))*TT2
17    E(I1)=(CX*T2X(I)+CY*T2Y(I)+CZ*T2Z(I))*TT2
      IF (KSYMP.EQ.1) RETURN
      TT1=(CY*CPH-CX*SPH)*(RRV-RRH)
      CX=-(RRH*CX-TT1*SPH)
      CY=-(RRH*CY+TT1*CPH)
      CZ=RRH*CZ
      I=LD+1
      I1=N-1
      DO 18 IS=1,M
      I=I-1
      I1=I1+2
      I2=I1+1
      ARG=-TP*(WX*X(I)+WY*Y(I)-WZ*Z(I))
      TT1=DCMPLX(COS(ARG),SIN(ARG))*SALP(I)*RETA
      E(I2)=E(I2)+(CX*T1X(I)+CY*T1Y(I)+CZ*T1Z(I))*TT1
18    E(I1)=E(I1)+(CX*T2X(I)+CY*T2Y(I)+CZ*T2Z(I))*TT1
      RETURN
!
!     INCIDENT FIELD OF AN ELEMENTARY CURRENT SOURCE.
!
19    WZ=COS(P4)
      WX=WZ*COS(P5)
      WY=WZ*SIN(P5)
      WZ=SIN(P4)
      DS=P6*59.958
      DSH=P6/(2.*TP)
      NPM=N+M
      IS=LD+1
      I1=N-1
      DO 24 I=1,NPM
      II=I
      IF (I.LE.N) GO TO 20
      IS=IS-1
      II=IS
      I1=I1+2
      I2=I1+1
20    PX=X(II)-P1
      PY=Y(II)-P2
      PZ=Z(II)-P3
      RS=PX*PX+PY*PY+PZ*PZ
      IF (RS.LT.1.D-30) GO TO 24
      R=SQRT(RS)
      PX=PX/R
      PY=PY/R
      PZ=PZ/R
      CTH=PX*WX+PY*WY+PZ*WZ
      STH=SQRT(1.-CTH*CTH)
      QX=PX-WX*CTH
      QY=PY-WY*CTH
      QZ=PZ-WZ*CTH
      ARG=SQRT(QX*QX+QY*QY+QZ*QZ)
      IF (ARG.LT.1.D-30) GO TO 21
      QX=QX/ARG
      QY=QY/ARG
      QZ=QZ/ARG
      GO TO 22
21    QX=1.
      QY=0.
      QZ=0.
22    ARG=-TP*R
      TT1=DCMPLX(COS(ARG),SIN(ARG))
      IF (I.GT.N) GO TO 23
      TT2=DCMPLX(1.D+0,-1.D+0/(R*TP))/RS
      ER=DS*TT1*TT2*CTH
      ET=.5*DS*TT1*((0.,1.)*TP/R+TT2)*STH
      EZH=ER*CTH-ET*STH
      ERH=ER*STH+ET*CTH
      CX=EZH*WX+ERH*QX
      CY=EZH*WY+ERH*QY
      CZ=EZH*WZ+ERH*QZ
      E(I)=-(CX*CAB(I)+CY*SAB(I)+CZ*SALP(I))
      GO TO 24
23    PX=WY*QZ-WZ*QY
      PY=WZ*QX-WX*QZ
      PZ=WX*QY-WY*QX
      TT2=DSH*TT1*DCMPLX(1./R,TP)/R*STH*SALP(II)
      CX=TT2*PX
      CY=TT2*PY
      CZ=TT2*PZ
      E(I2)=CX*T1X(II)+CY*T1Y(II)+CZ*T1Z(II)
      E(I1)=CX*T2X(II)+CY*T2Y(II)+CZ*T2Z(II)
24    CONTINUE
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE FACGF (A,B,C,D,BX,IP,IX,NP,N1,MP,M1,N1C,N2C)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     FACGF COMPUTES AND FACTORS D-C(INV(A)B).
      COMPLEX*16 A,B,C,D,BX,SUM
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      DIMENSION A(1), B(N1C,1), C(N1C,1), D(N2C,1), BX(N1C,1), IP(1), IX
     1(1)
      IF (N2C.EQ.0) RETURN
      IBFL=14
      IF (ICASX.LT.3) GO TO 1
!     CONVERT B FROM BLOCKS OF ROWS ON T14 TO BLOCKS OF COL. ON T16
      CALL REBLK (B,C,N1C,NPBX,N2C)
      IBFL=16
1     NPB=NPBL
      IF (ICASX.EQ.2) REWIND 14
!     COMPUTE INV(A)B AND WRITE ON TAPE14
      DO 2 IB=1,NBBL
      IF (IB.EQ.NBBL) NPB=NLBL
      IF (ICASX.GT.1) READ (IBFL) ((BX(I,J),I=1,N1C),J=1,NPB)
      CALL SOLVES (A,IP,BX,N1C,NPB,NP,N1,MP,M1,13,13)
      IF (ICASX.EQ.2) REWIND 14
      IF (ICASX.GT.1) WRITE (14) ((BX(I,J),I=1,N1C),J=1,NPB)
2     CONTINUE
      IF (ICASX.EQ.1) GO TO 3
      REWIND 11
      REWIND 12
      REWIND 15
      REWIND IBFL
3     NPC=NPBL
!     COMPUTE D-C(INV(A)B) AND WRITE ON TAPE11
      DO 8 IC=1,NBBL
      IF (IC.EQ.NBBL) NPC=NLBL
      IF (ICASX.EQ.1) GO TO 4
      READ (15) ((C(I,J),I=1,N1C),J=1,NPC)
      READ (12) ((D(I,J),I=1,N2C),J=1,NPC)
      REWIND 14
4     NPB=NPBL
      NIC=0
      DO 7 IB=1,NBBL
      IF (IB.EQ.NBBL) NPB=NLBL
      IF (ICASX.GT.1) READ (14) ((B(I,J),I=1,N1C),J=1,NPB)
      DO 6 I=1,NPB
      II=I+NIC
      DO 6 J=1,NPC
      SUM=(0.,0.)
      DO 5 K=1,N1C
5     SUM=SUM+B(K,I)*C(K,J)
6     D(II,J)=D(II,J)-SUM
7     NIC=NIC+NPBL
      IF (ICASX.GT.1) WRITE (11) ((D(I,J),I=1,N2C),J=1,NPBL)
8     CONTINUE
      IF (ICASX.EQ.1) GO TO 9
      REWIND 11
      REWIND 12
      REWIND 14
      REWIND 15
9     N1CP=N1C+1
!     FACTOR D-C(INV(A)B)
      IF (ICASX.GT.1) GO TO 10
      CALL FACTR (N2C,D,IP(N1CP),N2C)
      GO TO 13
10    IF (ICASX.EQ.4) GO TO 12
      NPB=NPBL
      IC=0
      DO 11 IB=1,NBBL
      IF (IB.EQ.NBBL) NPB=NLBL
      II=IC+1
      IC=IC+N2C*NPB
11    READ (11) (B(I,1),I=II,IC)
      REWIND 11
      CALL FACTR (N2C,B,IP(N1CP),N2C)
      NIC=N2C*N2C
      WRITE (11) (B(I,1),I=1,NIC)
      REWIND 11
      GO TO 13
12    NBLSYS=NBLSYM
      NPSYS=NPSYM
      NLSYS=NLSYM
      ICASS=ICASE
      NBLSYM=NBBL
      NPSYM=NPBL
      NLSYM=NLBL
      ICASE=3
      CALL FACIO (B,N2C,1,IX(N1CP),11,12,16,11)
      CALL LUNSCR (B,N2C,1,IP(N1CP),IX(N1CP),12,11,16)
      NBLSYM=NBLSYS
      NPSYM=NPSYS
      NLSYM=NLSYS
      ICASE=ICASS
13    RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE FACIO (A,NROW,NOP,IP,IU1,IU2,IU3,IU4)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     FACIO CONTROLS I/O FOR OUT-OF-CORE FACTORIZATION
!
      REAL T1, T2, TIME         ! hwh

      COMPLEX*16 A
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      DIMENSION A(NROW,1), IP(NROW)
      IT=2*NPSYM*NROW
      NBM=NBLSYM-1
      I1=1
      I2=IT
      I3=I2+1
      I4=2*IT
      TIME=0.
      REWIND IU1
      REWIND IU2
      DO 3 KK=1,NOP
      KA=(KK-1)*NROW+1
      IFILE3=IU1
      IFILE4=IU3
      DO 2 IXBLK1=1,NBM
      REWIND IU3
      REWIND IU4
      CALL BLCKIN (A,IFILE3,I1,I2,1,17)
      IXBP=IXBLK1+1
      DO 1 IXBLK2=IXBP,NBLSYM
      CALL BLCKIN (A,IFILE3,I3,I4,1,18)
      CALL SECOND (T1)
      CALL LFACTR (A,NROW,IXBLK1,IXBLK2,IP(KA))
      CALL SECOND (T2)
      TIME=TIME+T2-T1
      IF (IXBLK2.EQ.IXBP) CALL BLCKOT (A,IU2,I1,I2,1,19)
      IF (IXBLK1.EQ.NBM.AND.IXBLK2.EQ.NBLSYM) IFILE4=IU2
      CALL BLCKOT (A,IFILE4,I3,I4,1,20)
1     CONTINUE
      IFILE3=IU3
      IFILE4=IU4
      IF ((IXBLK1/2)*2.NE.IXBLK1) GO TO 2
      IFILE3=IU4
      IFILE4=IU3
2     CONTINUE
3     CONTINUE
      REWIND IU1
      REWIND IU2
      REWIND IU3
      REWIND IU4
      WRITE(3,4)  TIME
      RETURN
!
4     FORMAT (35H CP TIME TAKEN FOR FACTORIZATION = ,1P,E12.5)
      END
!----------------------------------------------------------------------------

      SUBROUTINE FACTR (N,A,IP,NDIM)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     SUBROUTINE TO FACTOR A MATRIX INTO A UNIT LOWER TRIANGULAR MATRIX
!     AND AN UPPER TRIANGULAR MATRIX USING THE GAUSS-DOOLITTLE ALGORITHM
!     PRESENTED ON PAGES 411-416 OF A. RALSTON--A FIRST COURSE IN
!     NUMERICAL ANALYSIS.  COMMENTS BELOW REFER TO COMMENTS IN RALSTONS
!     TEXT.    (MATRIX TRANSPOSED.
!
      COMPLEX*16 A,D,ARJ
      DIMENSION A(NDIM,NDIM), IP(NDIM)
      COMMON /SCRATM/ D(2*MAXSEG)
      INTEGER R,RM1,RP1,PJ,PR
!
!     Un-transpose the matrix for Gauss elimination
!
      DO 12 I=2,N
         DO 11 J=1,I-1
            ARJ=A(I,J)
            A(I,J)=A(J,I)
            A(J,I)=ARJ
11       CONTINUE
12    CONTINUE
      IFLG=0
      DO 9 R=1,N
!
!     STEP 1
!
      DO 1 K=1,N
      D(K)=A(K,R)
1     CONTINUE
!
!     STEPS 2 AND 3
!
      RM1=R-1
      IF (RM1.LT.1) GO TO 4
      DO 3 J=1,RM1
      PJ=IP(J)
      ARJ=D(PJ)
      A(J,R)=ARJ
      D(PJ)=D(J)
      JP1=J+1
      DO 2 I=JP1,N
      D(I)=D(I)-A(I,J)*ARJ
2     CONTINUE
3     CONTINUE
4     CONTINUE
!
!     STEP 4
!
      DMAX=DREAL(D(R)*DCONJG(D(R)))
      IP(R)=R
      RP1=R+1
      IF (RP1.GT.N) GO TO 6
      DO 5 I=RP1,N
      ELMAG=DREAL(D(I)*DCONJG(D(I)))
      IF (ELMAG.LT.DMAX) GO TO 5
      DMAX=ELMAG
      IP(R)=I
5     CONTINUE
6     CONTINUE
      IF (DMAX.LT.1.D-10) IFLG=1
      PR=IP(R)
      A(R,R)=D(PR)
      D(PR)=D(R)
!
!     STEP 5
!
      IF (RP1.GT.N) GO TO 8
      ARJ=1./A(R,R)
      DO 7 I=RP1,N
      A(I,R)=D(I)*ARJ
7     CONTINUE
8     CONTINUE
      IF (IFLG.EQ.0) GO TO 9
      WRITE(3,10)  R,DMAX
      IFLG=0
9     CONTINUE
      RETURN
!
10    FORMAT (1H ,6HPIVOT(,I3,2H)=,1P,E16.8)
      END
!----------------------------------------------------------------------------

      SUBROUTINE FACTRS (NP,NROW,A,IP,IX,IU1,IU2,IU3,IU4)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     FACTRS, FOR SYMMETRIC STRUCTURE, TRANSFORMS SUBMATRICIES TO FORM
!     MATRICIES OF THE SYMMETRIC MODES AND CALLS ROUTINE TO FACTOR
!     MATRICIES.  IF NO SYMMETRY, THE ROUTINE IS CALLED TO FACTOR THE
!     COMPLETE MATRIX.
!
      COMPLEX*16 A
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      DIMENSION A(1), IP(NROW), IX(NROW)
      NOP=NROW/NP
      IF (ICASE.GT.2) GO TO 2
      DO 1 KK=1,NOP
      KA=(KK-1)*NP+1
1     CALL FACTR (NP,A(KA),IP(KA),NROW)
      RETURN
2     IF (ICASE.GT.3) GO TO 3
!
!     FACTOR SUBMATRICIES, OR FACTOR COMPLETE MATRIX IF NO SYMMETRY
!     EXISTS.
!
      CALL FACIO (A,NROW,NOP,IX,IU1,IU2,IU3,IU4)
      CALL LUNSCR (A,NROW,NOP,IP,IX,IU2,IU3,IU4)
      RETURN
!
!     REWRITE THE MATRICES BY COLUMNS ON TAPE 13
!
3     I2=2*NPBLK*NROW
      REWIND IU2
      DO 5 K=1,NOP
      REWIND IU1
      ICOLS=NPBLK
      IR2=K*NP
      IR1=IR2-NP+1
      DO 5 L=1,NBLOKS
      IF (NBLOKS.EQ.1.AND.K.GT.1) GO TO 4
      CALL BLCKIN (A,IU1,1,I2,1,602)
      IF (L.EQ.NBLOKS) ICOLS=NLAST
4     IRR1=IR1
      IRR2=IR2
      DO 5 ICOLDX=1,ICOLS
      WRITE (IU2) (A(I),I=IRR1,IRR2)
      IRR1=IRR1+NROW
      IRR2=IRR2+NROW
5     CONTINUE
      REWIND IU1
      REWIND IU2
      IF (ICASE.EQ.5) GO TO 8
      REWIND IU3
      IRR1=NP*NP
      DO 7 KK=1,NOP
      IR1=1-NP
      IR2=0
      DO 6 I=1,NP
      IR1=IR1+NP
      IR2=IR2+NP
6     READ (IU2) (A(J),J=IR1,IR2)
      KA=(KK-1)*NP+1
      CALL FACTR (NP,A,IP(KA),NP)
      WRITE (IU3) (A(I),I=1,IRR1)
7     CONTINUE
      REWIND IU2
      REWIND IU3
      RETURN
8     I2=2*NPSYM*NP
      DO 10 KK=1,NOP
      J2=NPSYM
      DO 10 L=1,NBLSYM
      IF (L.EQ.NBLSYM) J2=NLSYM
      IR1=1-NP
      IR2=0
      DO 9 J=1,J2
      IR1=IR1+NP
      IR2=IR2+NP
9     READ (IU2) (A(I),I=IR1,IR2)
10    CALL BLCKOT (A,IU1,1,I2,1,193)
      REWIND IU1
      CALL FACIO (A,NP,NOP,IX,IU1,IU2,IU3,IU4)
      CALL LUNSCR (A,NP,NOP,IP,IX,IU2,IU3,IU4)
      RETURN
      END
      COMPLEX*16 FUNCTION FBAR(P)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     FBAR IS SOMMERFELD ATTENUATION FUNCTION FOR NUMERICAL DISTANCE P
!
      COMPLEX*16 Z,ZS,SUM,POW,TERM,P,FJ
      DIMENSION FJX(2)
      EQUIVALENCE (FJ,FJX)
      DATA TOSP/1.128379167D+0/,ACCS/1.D-12/,SP/1.772453851D+0/
     1,FJX/0.,1./
      Z=FJ*SQRT(P)
      IF (ABS(Z).GT.3.) GO TO 3
!
!     SERIES EXPANSION
!
      ZS=Z*Z
      SUM=Z
      POW=Z
      DO 1 I=1,100
      POW=-POW*ZS/DFLOAT(I)
      TERM=POW/(2.*I+1.)
      SUM=SUM+TERM
      TMS=DREAL(TERM*DCONJG(TERM))
      SMS=DREAL(SUM*DCONJG(SUM))
      IF (TMS/SMS.LT.ACCS) GO TO 2
1     CONTINUE
2     FBAR=1.-(1.-SUM*TOSP)*Z*EXP(ZS)*SP
      RETURN
!
!     ASYMPTOTIC EXPANSION
!
3     IF (DREAL(Z).GE.0.) GO TO 4
      MINUS=1
      Z=-Z
      GO TO 5
4     MINUS=0
5     ZS=.5/(Z*Z)
      SUM=(0.,0.)
      TERM=(1.,0.)
      DO 6 I=1,6
      TERM=-TERM*(2.*I-1.)*ZS
6     SUM=SUM+TERM
      IF (MINUS.EQ.1) SUM=SUM-2.*SP*Z*EXP(Z*Z)
      FBAR=-SUM
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE FBLOCK (NROW,NCOL,IMAX,IRNGF,IPSYM)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     FBLOCK SETS PARAMETERS FOR OUT-OF-CORE SOLUTION FOR THE PRIMARY
!     MATRIX (A)
      COMPLEX*16 SSX,DETER
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      COMMON /SMAT/ SSX(16,16)
      IMX1=IMAX-IRNGF
      IF (NROW*NCOL.GT.IMX1) GO TO 2
      NBLOKS=1
      NPBLK=NROW
      NLAST=NROW
      IMAT=NROW*NCOL
      IF (NROW.NE.NCOL) GO TO 1
      ICASE=1
      RETURN
1     ICASE=2
      GO TO 5
2     IF (NROW.NE.NCOL) GO TO 3
      ICASE=3
      NPBLK=IMAX/(2*NCOL)
      NPSYM=IMX1/NCOL
      IF (NPSYM.LT.NPBLK) NPBLK=NPSYM
      IF (NPBLK.LT.1) GO TO 12
      NBLOKS=(NROW-1)/NPBLK
      NLAST=NROW-NBLOKS*NPBLK
      NBLOKS=NBLOKS+1
      NBLSYM=NBLOKS
      NPSYM=NPBLK
      NLSYM=NLAST
      IMAT=NPBLK*NCOL
      WRITE(3,14)  NBLOKS,NPBLK,NLAST
      GO TO 11
3     NPBLK=IMAX/NCOL
      IF (NPBLK.LT.1) GO TO 12
      IF (NPBLK.GT.NROW) NPBLK=NROW
      NBLOKS=(NROW-1)/NPBLK
      NLAST=NROW-NBLOKS*NPBLK
      NBLOKS=NBLOKS+1
      WRITE(3,14)  NBLOKS,NPBLK,NLAST
      IF (NROW*NROW.GT.IMX1) GO TO 4
      ICASE=4
      NBLSYM=1
      NPSYM=NROW
      NLSYM=NROW
      IMAT=NROW*NROW
      WRITE(3,15)
      GO TO 5
4     ICASE=5
      NPSYM=IMAX/(2*NROW)
      NBLSYM=IMX1/NROW
      IF (NBLSYM.LT.NPSYM) NPSYM=NBLSYM
      IF (NPSYM.LT.1) GO TO 12
      NBLSYM=(NROW-1)/NPSYM
      NLSYM=NROW-NBLSYM*NPSYM
      NBLSYM=NBLSYM+1
      WRITE(3,16)  NBLSYM,NPSYM,NLSYM
      IMAT=NPSYM*NROW
5     NOP=NCOL/NROW
      IF (NOP*NROW.NE.NCOL) GO TO 13
      IF (IPSYM.GT.0) GO TO 7
!
!     SET UP SSX MATRIX FOR ROTATIONAL SYMMETRY.
!
      PHAZ=6.2831853072D+0/NOP
      DO 6 I=2,NOP
      DO 6 J=I,NOP
      ARG=PHAZ*DFLOAT(I-1)*DFLOAT(J-1)
      SSX(I,J)=DCMPLX(COS(ARG),SIN(ARG))
6     SSX(J,I)=SSX(I,J)
      GO TO 11
!
!     SET UP SSX MATRIX FOR PLANE SYMMETRY
!
7     KK=1
      SSX(1,1)=(1.,0.)
      IF ((NOP.EQ.2).OR.(NOP.EQ.4).OR.(NOP.EQ.8)) GO TO 8
      STOP
8     KA=NOP/2
      IF (NOP.EQ.8) KA=3
      DO 10 K=1,KA
      DO 9 I=1,KK
      DO 9 J=1,KK
      DETER=SSX(I,J)
      SSX(I,J+KK)=DETER
      SSX(I+KK,J+KK)=-DETER
9     SSX(I+KK,J)=DETER
10    KK=KK*2
11    RETURN
12    WRITE(3,17)  NROW,NCOL
      STOP
13    WRITE(3,18)  NROW,NCOL
      STOP
!
14    FORMAT (//35H MATRIX FILE STORAGE -  NO. BLOCKS=,I5,19H COLUMNS PE
     1R BLOCK=,I5,23H COLUMNS IN LAST BLOCK=,I5)
15    FORMAT (25H SUBMATRICIES FIT IN CORE)
16    FORMAT (38H SUBMATRIX PARTITIONING -  NO. BLOCKS=,I5,19H COLUMNS P
     1ER BLOCK=,I5,23H COLUMNS IN LAST BLOCK=,I5)
17    FORMAT (40H ERROR - INSUFFICIENT STORAGE FOR MATRIX,2I5)
18    FORMAT (28H SYMMETRY ERROR - NROW,NCOL=,2I5)
      END
!----------------------------------------------------------------------------

      SUBROUTINE FBNGF (NEQ,NEQ2,IRESRV,IB11,IC11,ID11,IX11)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     FBNGF SETS THE BLOCKING PARAMETERS FOR THE B, C, AND D ARRAYS FOR
!     OUT-OF-CORE STORAGE.
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      IRESX=IRESRV-IMAT
      NBLN=NEQ*NEQ2
      NDLN=NEQ2*NEQ2
      NBCD=2*NBLN+NDLN
      IF (NBCD.GT.IRESX) GO TO 1
      ICASX=1
      IB11=IMAT+1
      GO TO 2
1     IF (ICASE.LT.3) GO TO 3
      IF (NBCD.GT.IRESRV.OR.NBLN.GT.IRESX) GO TO 3
      ICASX=2
      IB11=1
2     NBBX=1
      NPBX=NEQ
      NLBX=NEQ
      NBBL=1
      NPBL=NEQ2
      NLBL=NEQ2
      GO TO 5
3     IR=IRESRV
      IF (ICASE.LT.3) IR=IRESX
      ICASX=3
      IF (NDLN.GT.IR) ICASX=4
      NBCD=2*NEQ+NEQ2
      NPBL=IR/NBCD
      NLBL=IR/(2*NEQ2)
      IF (NLBL.LT.NPBL) NPBL=NLBL
      IF (ICASE.LT.3) GO TO 4
      NLBL=IRESX/NEQ
      IF (NLBL.LT.NPBL) NPBL=NLBL
4     IF (NPBL.LT.1) GO TO 6
      NBBL=(NEQ2-1)/NPBL
      NLBL=NEQ2-NBBL*NPBL
      NBBL=NBBL+1
      NBLN=NEQ*NPBL
      IR=IR-NBLN
      NPBX=IR/NEQ2
      IF (NPBX.GT.NEQ) NPBX=NEQ
      NBBX=(NEQ-1)/NPBX
      NLBX=NEQ-NBBX*NPBX
      NBBX=NBBX+1
      IB11=1
      IF (ICASE.LT.3) IB11=IMAT+1
5     IC11=IB11+NBLN
      ID11=IC11+NBLN
      IX11=IMAT+1
      WRITE(3,11)  NEQ2
      IF (ICASX.EQ.1) RETURN
      WRITE(3,8)  ICASX
      WRITE(3,9)  NBBX,NPBX,NLBX
      WRITE(3,10)  NBBL,NPBL,NLBL
      RETURN
6     WRITE(3,7)  IRESRV,IMAT,NEQ,NEQ2
      STOP
!
7     FORMAT (55H ERROR - INSUFFICIENT STORAGE FOR INTERACTION MATRICIES
     1,24H  IRESRV,IMAT,NEQ,NEQ2 =,4I5)
8     FORMAT (48H FILE STORAGE FOR NEW MATRIX SECTIONS -  ICASX =,I2)
9     FORMAT (19H B FILLED BY ROWS -,15X,12HNO. BLOCKS =,I3,3X,16HROWS P
     1ER BLOCK =,I3,3X,20HROWS IN LAST BLOCK =,I3)
10    FORMAT (32H B BY COLUMNS, C AND D BY ROWS -,2X,12HNO. BLOCKS =,I3,
     14X,15HR/C PER BLOCK =,I3,4X,19HR/C IN LAST BLOCK =,I3)
11    FORMAT (//,35H N.G.F. - NUMBER OF NEW UNKNOWNS IS,I4)
      END
!----------------------------------------------------------------------------

      SUBROUTINE FFLD (THET,PHI,ETH,EPH)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     FFLD CALCULATES THE FAR ZONE RADIATED ELECTRIC FIELDS,
!     THE FACTOR EXP(J*K*R)/(R/LAMDA) NOT INCLUDED
!
      COMPLEX*16 CIX,CIY,CIZ,EXA,ETH,EPH,CONST,CCX,CCY,CCZ,CDP,CUR
      COMPLEX*16 ZRATI,ZRSIN,RRV,RRH,RRV1,RRH1,RRV2,RRH2,ZRATI2,TIX,TIY
     1,TIZ,T1,ZSCRN,EX,EY,EZ,GX,GY,GZ,FRATI
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
      COMMON /CRNT/ AIR(MAXSEG),AII(MAXSEG),BIR(MAXSEG),BII(MAXSEG),
     &CIR(MAXSEG),CII(MAXSEG),CUR(3*MAXSEG)
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      DIMENSION CAB(1), SAB(1), CONSX(2)
      EQUIVALENCE (CAB,ALP), (SAB,BET), (CONST,CONSX)
      DATA PI,TP,ETA/3.141592654D+0,6.283185308D+0,376.73/
      DATA CONSX/0.,-29.97922085D+0/
      PHX=-SIN(PHI)
      PHY=COS(PHI)
      ROZ=COS(THET)
      ROZS=ROZ
      THX=ROZ*PHY
      THY=-ROZ*PHX
      THZ=-SIN(THET)
      ROX=-THZ*PHY
      ROY=THZ*PHX
      IF (N.EQ.0) GO TO 20
!
!     LOOP FOR STRUCTURE IMAGE IF ANY
!
      DO 19 K=1,KSYMP
!
!     CALCULATION OF REFLECTION COEFFECIENTS
!
      IF (K.EQ.1) GO TO 4
      IF (IPERF.NE.1) GO TO 1
!
!     FOR PERFECT GROUND
!
      RRV=-(1.,0.)
      RRH=-(1.,0.)
      GO TO 2
!
!     FOR INFINITE PLANAR GROUND
!
1     ZRSIN=SQRT(1.-ZRATI*ZRATI*THZ*THZ)
      RRV=-(ROZ-ZRATI*ZRSIN)/(ROZ+ZRATI*ZRSIN)
      RRH=(ZRATI*ROZ-ZRSIN)/(ZRATI*ROZ+ZRSIN)
2     IF (IFAR.LE.1) GO TO 3
!
!     FOR THE CLIFF PROBLEM, TWO REFLCTION COEFFICIENTS CALCULATED
!
      RRV1=RRV
      RRH1=RRH
      TTHET=TAN(THET)
      IF (IFAR.EQ.4) GO TO 3
      ZRSIN=SQRT(1.-ZRATI2*ZRATI2*THZ*THZ)
      RRV2=-(ROZ-ZRATI2*ZRSIN)/(ROZ+ZRATI2*ZRSIN)
      RRH2=(ZRATI2*ROZ-ZRSIN)/(ZRATI2*ROZ+ZRSIN)
      DARG=-TP*2.*CH*ROZ
3     ROZ=-ROZ
      CCX=CIX
      CCY=CIY
      CCZ=CIZ
4     CIX=(0.,0.)
      CIY=(0.,0.)
      CIZ=(0.,0.)
!
!     LOOP OVER STRUCTURE SEGMENTS
!
      DO 17 I=1,N
      OMEGA=-(ROX*CAB(I)+ROY*SAB(I)+ROZ*SALP(I))
      EL=PI*SI(I)
      SILL=OMEGA*EL
      TOP=EL+SILL
      BOT=EL-SILL
      IF (ABS(OMEGA).LT.1.D-7) GO TO 5
      A=2.*SIN(SILL)/OMEGA
      GO TO 6
5     A=(2.-OMEGA*OMEGA*EL*EL/3.)*EL
6     IF (ABS(TOP).LT.1.D-7) GO TO 7
      TOO=SIN(TOP)/TOP
      GO TO 8
7     TOO=1.-TOP*TOP/6.
8     IF (ABS(BOT).LT.1.D-7) GO TO 9
      BOO=SIN(BOT)/BOT
      GO TO 10
9     BOO=1.-BOT*BOT/6.
10    B=EL*(BOO-TOO)
      C=EL*(BOO+TOO)
      RR=A*AIR(I)+B*BII(I)+C*CIR(I)
      RI=A*AII(I)-B*BIR(I)+C*CII(I)
      ARG=TP*(X(I)*ROX+Y(I)*ROY+Z(I)*ROZ)
      IF (K.EQ.2.AND.IFAR.GE.2) GO TO 11
      EXA=DCMPLX(COS(ARG),SIN(ARG))*DCMPLX(RR,RI)
!
!     SUMMATION FOR FAR FIELD INTEGRAL
!
      CIX=CIX+EXA*CAB(I)
      CIY=CIY+EXA*SAB(I)
      CIZ=CIZ+EXA*SALP(I)
      GO TO 17
!
!     CALCULATION OF IMAGE CONTRIBUTION IN CLIFF AND GROUND SCREEN
!     PROBLEMS.
!
11    DR=Z(I)*TTHET
!
!     SPECULAR POINT DISTANCE
!
      D=DR*PHY+X(I)
      IF (IFAR.EQ.2) GO TO 13
      D=SQRT(D*D+(Y(I)-DR*PHX)**2)
      IF (IFAR.EQ.3) GO TO 13
      IF ((SCRWL-D).LT.0.) GO TO 12
!
!     RADIAL WIRE GROUND SCREEN REFLECTION COEFFICIENT
!
      D=D+T2
      ZSCRN=T1*D*LOG(D/T2)
      ZSCRN=(ZSCRN*ZRATI)/(ETA*ZRATI+ZSCRN)
      ZRSIN=SQRT(1.-ZSCRN*ZSCRN*THZ*THZ)
      RRV=(ROZ+ZSCRN*ZRSIN)/(-ROZ+ZSCRN*ZRSIN)
      RRH=(ZSCRN*ROZ+ZRSIN)/(ZSCRN*ROZ-ZRSIN)
      GO TO 16
12    IF (IFAR.EQ.4) GO TO 14
      IF (IFAR.EQ.5) D=DR*PHY+X(I)
13    IF ((CL-D).LE.0.) GO TO 15
14    RRV=RRV1
      RRH=RRH1
      GO TO 16
15    RRV=RRV2
      RRH=RRH2
      ARG=ARG+DARG
16    EXA=DCMPLX(COS(ARG),SIN(ARG))*DCMPLX(RR,RI)
!
!     CONTRIBUTION OF EACH IMAGE SEGMENT MODIFIED BY REFLECTION COEF. ,
!     FOR CLIFF AND GROUND SCREEN PROBLEMS
!
      TIX=EXA*CAB(I)
      TIY=EXA*SAB(I)
      TIZ=EXA*SALP(I)
      CDP=(TIX*PHX+TIY*PHY)*(RRH-RRV)
      CIX=CIX+TIX*RRV+CDP*PHX
      CIY=CIY+TIY*RRV+CDP*PHY
      CIZ=CIZ-TIZ*RRV
17    CONTINUE
      IF (K.EQ.1) GO TO 19
      IF (IFAR.GE.2) GO TO 18
!
!     CALCULATION OF CONTRIBUTION OF STRUCTURE IMAGE FOR INFINITE GROUND
!
      CDP=(CIX*PHX+CIY*PHY)*(RRH-RRV)
      CIX=CCX+CIX*RRV+CDP*PHX
      CIY=CCY+CIY*RRV+CDP*PHY
      CIZ=CCZ-CIZ*RRV
      GO TO 19
18    CIX=CIX+CCX
      CIY=CIY+CCY
      CIZ=CIZ+CCZ
19    CONTINUE
      IF (M.GT.0) GO TO 21
      ETH=(CIX*THX+CIY*THY+CIZ*THZ)*CONST
      EPH=(CIX*PHX+CIY*PHY)*CONST
      RETURN
20    CIX=(0.,0.)
      CIY=(0.,0.)
      CIZ=(0.,0.)
21    ROZ=ROZS
!
!     ELECTRIC FIELD COMPONENTS
!
      RFL=-1.
      DO 25 IP=1,KSYMP
      RFL=-RFL
      RRZ=ROZ*RFL
      CALL FFLDS (ROX,ROY,RRZ,CUR(N+1),GX,GY,GZ)
      IF (IP.EQ.2) GO TO 22
      EX=GX
      EY=GY
      EZ=GZ
      GO TO 25
22    IF (IPERF.NE.1) GO TO 23
      GX=-GX
      GY=-GY
      GZ=-GZ
      GO TO 24
23    RRV=SQRT(1.-ZRATI*ZRATI*THZ*THZ)
      RRH=ZRATI*ROZ
      RRH=(RRH-RRV)/(RRH+RRV)
      RRV=ZRATI*RRV
      RRV=-(ROZ-RRV)/(ROZ+RRV)
      ETH=(GX*PHX+GY*PHY)*(RRH-RRV)
      GX=GX*RRV+ETH*PHX
      GY=GY*RRV+ETH*PHY
      GZ=GZ*RRV
24    EX=EX+GX
      EY=EY+GY
      EZ=EZ-GZ
25    CONTINUE
      EX=EX+CIX*CONST
      EY=EY+CIY*CONST
      EZ=EZ+CIZ*CONST
      ETH=EX*THX+EY*THY+EZ*THZ
      EPH=EX*PHX+EY*PHY
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE FFLDS (ROX,ROY,ROZ,SCUR,EX,EY,EZ)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     CALCULATES THE XYZ COMPONENTS OF THE ELECTRIC FIELD DUE TO
!     SURFACE CURRENTS
      COMPLEX*16 CT,CONS,SCUR,EX,EY,EZ
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      DIMENSION XS(1), YS(1), ZS(1), S(1), SCUR(1), CONSX(2)
      EQUIVALENCE (XS,X), (YS,Y), (ZS,Z), (S,BI), (CONS,CONSX)
      DATA TPI/6.283185308D+0/,CONSX/0.,188.365/
      EX=(0.,0.)
      EY=(0.,0.)
      EZ=(0.,0.)
      I=LD+1
      DO 1 J=1,M
      I=I-1
      ARG=TPI*(ROX*XS(I)+ROY*YS(I)+ROZ*ZS(I))
      CT=DCMPLX(COS(ARG)*S(I),SIN(ARG)*S(I))
      K=3*J
      EX=EX+SCUR(K-2)*CT
      EY=EY+SCUR(K-1)*CT
      EZ=EZ+SCUR(K)*CT
1     CONTINUE
      CT=ROX*EX+ROY*EY+ROZ*EZ
      EX=CONS*(CT*ROX-EX)
      EY=CONS*(CT*ROY-EY)
      EZ=CONS*(CT*ROZ-EZ)
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE GF (ZK,CO,SI)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     GF COMPUTES THE INTEGRAND EXP(JKR)/(KR) FOR NUMERICAL INTEGRATION.
!
      COMMON /TMI/ ZPK,RKB2,IJ
      ZDK=ZK-ZPK
      RK=SQRT(RKB2+ZDK*ZDK)
      SI=SIN(RK)/RK
      IF (IJ) 1,2,1
1     CO=COS(RK)/RK
      RETURN
2     IF (RK.LT..2) GO TO 3
      CO=(COS(RK)-1.)/RK
      RETURN
3     RKS=RK*RK
      CO=((-1.38888889D-3*RKS+4.16666667D-2)*RKS-.5)*RK
      RETURN
      END

!----------------------------------------------------------------------------

      SUBROUTINE GFIL (IPRT)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      PARAMETER (IRESRV=MAXMAT**2)
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     GFIL READS THE N.G.F. FILE
!
      COMPLEX*16 CM,SSX,ZRATI,ZRATI2,T1,ZARRAY,AR1,AR2,AR3,EPSCF,FRATI
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /CMB/ CM(IRESRV)
      COMMON /ANGL/ SALP(MAXSEG)
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      COMMON /GGRID/ AR1(11,10,4),AR2(17,5,4),AR3(9,8,4),EPSCF,DXA(3),DY
     1A(3),XSA(3),YSA(3),NXA(3),NYA(3)
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      COMMON /SMAT/ SSX(16,16)
      COMMON /ZLOAD/ ZARRAY(MAXSEG),NLOAD,NLODF
      COMMON/SAVE/EPSR,SIG,SCRWLT,SCRWRT,FMHZ,IP(2*MAXSEG),KCOM
      COMMON/CSAVE/COM(19,5)

	character ngfnam*80		! av12
	common /ngfnam/ ngfnam		! av12
!
!*** ERROR CORRECTED 11/20/89 *******************************
      DIMENSION T2X(1),T2Y(1),T2Z(1)
      EQUIVALENCE (T2X,ICON1),(T2Y,ICON2),(T2Z,ITAG)
!***
      DATA IGFL/20/

	OPEN(UNIT=IGFL,FILE=NGFNAM,FORM='UNFORMATTED',STATUS='OLD',ERR=30)! av12
	goto 31										! av12

30	write (3, '(2A)') 'ERROR opening NGF-file : ',ngfnam			! av12
	stop											! av12
	
31    REWIND IGFL
      READ (IGFL) N1,NP,M1,MP,WLAM,FMHZ,IPSYM,KSYMP,IPERF,NRADL,EPSR,SIG
     1,SCRWLT,SCRWRT,NLODF,KCOM
      N=N1
      M=M1
      N2=N1+1
      M2=M1+1
      IF (N1.EQ.0) GO TO 2
!     READ SEG. DATA AND CONVERT BACK TO END COORD. IN UNITS OF METERS
      READ (IGFL) (X(I),I=1,N1),(Y(I),I=1,N1),(Z(I),I=1,N1)
      READ (IGFL) (SI(I),I=1,N1),(BI(I),I=1,N1),(ALP(I),I=1,N1)
      READ (IGFL) (BET(I),I=1,N1),(SALP(I),I=1,N1)
      READ (IGFL) (ICON1(I),I=1,N1),(ICON2(I),I=1,N1)
      READ (IGFL) (ITAG(I),I=1,N1)
      IF (NLODF.NE.0) READ (IGFL) (ZARRAY(I),I=1,N1)
      DO 1 I=1,N1
      XI=X(I)*WLAM
      YI=Y(I)*WLAM
      ZI=Z(I)*WLAM
      DX=SI(I)*.5*WLAM
      X(I)=XI-ALP(I)*DX
      Y(I)=YI-BET(I)*DX
      Z(I)=ZI-SALP(I)*DX
      SI(I)=XI+ALP(I)*DX
      ALP(I)=YI+BET(I)*DX
      BET(I)=ZI+SALP(I)*DX
      BI(I)=BI(I)*WLAM
1     CONTINUE
2     IF (M1.EQ.0) GO TO 4
      J=LD-M1+1
!     READ PATCH DATA AND CONVERT TO METERS
      READ (IGFL) (X(I),I=J,LD),(Y(I),I=J,LD),(Z(I),I=J,LD)
      READ (IGFL) (SI(I),I=J,LD),(BI(I),I=J,LD),(ALP(I),I=J,LD)
      READ (IGFL) (BET(I),I=J,LD),(SALP(I),I=J,LD)
!*** ERROR CORRECTED 11/20/89 *******************************
      READ (IGFL) (T2X(I),I=J,LD),(T2Y(I),I=J,LD)
      READ (IGFL) (T2Z(I),I=J,LD)
!      READ (IGFL) (ICON1(I),I=J,LD),(ICON2(I),I=J,LD)
!      READ (IGFL) (ITAG(I),I=J,LD)
!
      DX=WLAM*WLAM
      DO 3 I=J,LD
      X(I)=X(I)*WLAM
      Y(I)=Y(I)*WLAM
      Z(I)=Z(I)*WLAM
3     BI(I)=BI(I)*DX
4     READ (IGFL) ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT
      IF (IPERF.EQ.2) READ (IGFL) AR1,AR2,AR3,EPSCF,DXA,DYA,XSA,YSA,NXA,
     1NYA
      NEQ=N1+2*M1
      NPEQ=NP+2*MP
      NOP=NEQ/NPEQ
      IF (NOP.GT.1) READ (IGFL) ((SSX(I,J),I=1,NOP),J=1,NOP)
      READ (IGFL) (IP(I),I=1,NEQ),COM
!     READ MATRIX A AND WRITE TAPE13 FOR OUT OF CORE
      IF (ICASE.GT.2) GO TO 5
      IOUT=NEQ*NPEQ
      READ (IGFL) (CM(I),I=1,IOUT)
      GO TO 10
5     REWIND 13
      IF (ICASE.NE.4) GO TO 7
      IOUT=NPEQ*NPEQ
      DO 6 K=1,NOP
      READ (IGFL) (CM(J),J=1,IOUT)
6     WRITE (13) (CM(J),J=1,IOUT)
      GO TO 9
7     IOUT=NPSYM*NPEQ*2
      NBL2=2*NBLSYM
      DO 8 IOP=1,NOP
      DO 8 I=1,NBL2
      CALL BLCKIN (CM,IGFL,1,IOUT,1,206)
8     CALL BLCKOT (CM,13,1,IOUT,1,205)
9     REWIND 13
10    REWIND IGFL
!     WRITE(3,N) G.F. HEADING
      WRITE(3,16)
      WRITE(3,14)
      WRITE(3,14)
      WRITE(3,17)
      WRITE(3,18)  N1,M1
      IF (NOP.GT.1) WRITE(3,19)  NOP
      WRITE(3,20)  IMAT,ICASE
      IF (ICASE.LT.3) GO TO 11
      NBL2=NEQ*NPEQ
      WRITE(3,21)  NBL2
11    WRITE(3,22)  FMHZ
      IF (KSYMP.EQ.2.AND.IPERF.EQ.1) WRITE(3,23)
      IF (KSYMP.EQ.2.AND.IPERF.EQ.0) WRITE(3,27)
      IF (KSYMP.EQ.2.AND.IPERF.EQ.2) WRITE(3,28)
      IF (KSYMP.EQ.2.AND.IPERF.NE.1) WRITE(3,24)  EPSR,SIG
      WRITE(3,17)
      DO 12 J=1,KCOM
12    WRITE(3,15)  (COM(I,J),I=1,19)
      WRITE(3,17)
      WRITE(3,14)
      WRITE(3,14)
      WRITE(3,16)
      IF (IPRT.EQ.0) RETURN
      WRITE(3,25)
      DO 13 I=1,N1
13    WRITE(3,26)  I,X(I),Y(I),Z(I),SI(I),ALP(I),BET(I)
      RETURN
!
14    FORMAT (5X,50H**************************************************,
     &34H**********************************)
15    FORMAT (5X,3H** ,19A4,3H **)
16    FORMAT (////)
17    FORMAT (5X,2H**,80X,2H**)
18    FORMAT (5X,29H** NUMERICAL GREEN'S FUNCTION,53X,2H**,/,5X,17H** NO
     1. SEGMENTS =,I4,10X,13HNO. PATCHES =,I4,34X,2H**)
19    FORMAT (5X,27H** NO. SYMMETRIC SECTIONS =,I4,51X,2H**)
20    FORMAT (5X,34H** N.G.F. MATRIX -  CORE STORAGE =,I7,23H COMPLEX NU
     1MBERS,  CASE,I2,16X,2H**)
21    FORMAT (5X,2H**,19X,13HMATRIX SIZE =,I7,16H COMPLEX NUMBERS,25X,2H
     1**)
22    FORMAT (5X,14H** FREQUENCY =,1P,E12.5,5H MHZ.,51X,2H**)
23    FORMAT (5X,17H** PERFECT GROUND,65X,2H**)
24    FORMAT (5X,44H** GROUND PARAMETERS - DIELECTRIC CONSTANT =,1P,
     1E12.5,26X,2H**,/,5X,2H**,21X,14HCONDUCTIVITY =,E12.5,8H MHOS/M.,
     225X,2H**)
25    FORMAT (39X,31HNUMERICAL GREEN'S FUNCTION DATA,/,41X,27HCOORDINATE
     1S OF SEGMENT ENDS,/,51X,8H(METERS),/,5X,4HSEG.,11X,19H- - - END ON
     2E - - -,26X,19H- - - END TWO - - -,/,6X,3HNO.,6X,1HX,14X,1HY,14X,1
     3HZ,14X,1HX,14X,1HY,14X,1HZ)
26    FORMAT (1X,I7,1P,6E15.6)
27    FORMAT (5X,55H** FINITE GROUND.  REFLECTION COEFFICIENT APPROXIMAT
     1ION,27X,2H**)
28    FORMAT (5X,38H** FINITE GROUND.  SOMMERFELD SOLUTION,44X,2H**)
      END
!----------------------------------------------------------------------------

      SUBROUTINE GFLD (RHO,PHI,RZ,ETH,EPI,ERD,UX,KSYMP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     GFLD COMPUTES THE RADIATED FIELD INCLUDING GROUND WAVE.
!
      COMPLEX*16 CUR,EPI,CIX,CIY,CIZ,EXA,XX1,XX2,U,U2,ERV,EZV,ERH,EPH
      COMPLEX*16 EZH,EX,EY,ETH,UX,ERD
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
      COMMON /CRNT/ AIR(MAXSEG),AII(MAXSEG),BIR(MAXSEG),BII(MAXSEG),
     &CIR(MAXSEG),CII(MAXSEG),CUR(3*MAXSEG)
      COMMON /GWAV/ U,U2,XX1,XX2,R1,R2,ZMH,ZPH
      DIMENSION CAB(1), SAB(1)
      EQUIVALENCE (CAB(1),ALP(1)), (SAB(1),BET(1))
      DATA PI,TP/3.141592654D+0,6.283185308D+0/
      R=SQRT(RHO*RHO+RZ*RZ)
      IF (KSYMP.EQ.1) GO TO 1
      IF (ABS(UX).GT..5) GO TO 1
      IF (R.GT.1.E5) GO TO 1
      GO TO 4
!
!     COMPUTATION OF SPACE WAVE ONLY
!
1     IF (RZ.LT.1.D-20) GO TO 2
      THET=ATAN(RHO/RZ)
      GO TO 3
2     THET=PI*.5
3     CALL FFLD (THET,PHI,ETH,EPI)
      ARG=-TP*R
      EXA=DCMPLX(COS(ARG),SIN(ARG))/R
      ETH=ETH*EXA
      EPI=EPI*EXA
      ERD=(0.,0.)
      RETURN
!
!     COMPUTATION OF SPACE AND GROUND WAVES.
!
4     U=UX
      U2=U*U
      PHX=-SIN(PHI)
      PHY=COS(PHI)
      RX=RHO*PHY
      RY=-RHO*PHX
      CIX=(0.,0.)
      CIY=(0.,0.)
      CIZ=(0.,0.)
!
!     SUMMATION OF FIELD FROM INDIVIDUAL SEGMENTS
!
      DO 17 I=1,N
      DX=CAB(I)
      DY=SAB(I)
      DZ=SALP(I)
      RIX=RX-X(I)
      RIY=RY-Y(I)
      RHS=RIX*RIX+RIY*RIY
      RHP=SQRT(RHS)
      IF (RHP.LT.1.D-6) GO TO 5
      RHX=RIX/RHP
      RHY=RIY/RHP
      GO TO 6
5     RHX=1.
      RHY=0.
6     CALP=1.-DZ*DZ
      IF (CALP.LT.1.D-6) GO TO 7
      CALP=SQRT(CALP)
      CBET=DX/CALP
      SBET=DY/CALP
      CPH=RHX*CBET+RHY*SBET
      SPH=RHY*CBET-RHX*SBET
      GO TO 8
7     CPH=RHX
      SPH=RHY
8     EL=PI*SI(I)
      RFL=-1.
!
!     INTEGRATION OF (CURRENT)*(PHASE FACTOR) OVER SEGMENT AND IMAGE FOR
!     CONSTANT, SINE, AND COSINE CURRENT DISTRIBUTIONS
!
      DO 16 K=1,2
      RFL=-RFL
      RIZ=RZ-Z(I)*RFL
      RXYZ=SQRT(RIX*RIX+RIY*RIY+RIZ*RIZ)
      RNX=RIX/RXYZ
      RNY=RIY/RXYZ
      RNZ=RIZ/RXYZ
      OMEGA=-(RNX*DX+RNY*DY+RNZ*DZ*RFL)
      SILL=OMEGA*EL
      TOP=EL+SILL
      BOT=EL-SILL
      IF (ABS(OMEGA).LT.1.D-7) GO TO 9
      A=2.*SIN(SILL)/OMEGA
      GO TO 10
9     A=(2.-OMEGA*OMEGA*EL*EL/3.)*EL
10    IF (ABS(TOP).LT.1.D-7) GO TO 11
      TOO=SIN(TOP)/TOP
      GO TO 12
11    TOO=1.-TOP*TOP/6.
12    IF (ABS(BOT).LT.1.D-7) GO TO 13
      BOO=SIN(BOT)/BOT
      GO TO 14
13    BOO=1.-BOT*BOT/6.
14    B=EL*(BOO-TOO)
      C=EL*(BOO+TOO)
      RR=A*AIR(I)+B*BII(I)+C*CIR(I)
      RI=A*AII(I)-B*BIR(I)+C*CII(I)
      ARG=TP*(X(I)*RNX+Y(I)*RNY+Z(I)*RNZ*RFL)
      EXA=DCMPLX(COS(ARG),SIN(ARG))*DCMPLX(RR,RI)/TP
      IF (K.EQ.2) GO TO 15
      XX1=EXA
      R1=RXYZ
      ZMH=RIZ
      GO TO 16
15    XX2=EXA
      R2=RXYZ
      ZPH=RIZ
16    CONTINUE
!
!     CALL SUBROUTINE TO COMPUTE THE FIELD OF SEGMENT INCLUDING GROUND
!     WAVE.
!
      CALL GWAVE (ERV,EZV,ERH,EZH,EPH)
      ERH=ERH*CPH*CALP+ERV*DZ
      EPH=EPH*SPH*CALP
      EZH=EZH*CPH*CALP+EZV*DZ
      EX=ERH*RHX-EPH*RHY
      EY=ERH*RHY+EPH*RHX
      CIX=CIX+EX
      CIY=CIY+EY
17    CIZ=CIZ+EZH
      ARG=-TP*R
      EXA=DCMPLX(COS(ARG),SIN(ARG))
      CIX=CIX*EXA
      CIY=CIY*EXA
      CIZ=CIZ*EXA
      RNX=RX/R
      RNY=RY/R
      RNZ=RZ/R
      THX=RNZ*PHY
      THY=-RNZ*PHX
      THZ=-RHO/R
      ETH=CIX*THX+CIY*THY+CIZ*THZ
      EPI=CIX*PHX+CIY*PHY
      ERD=CIX*RNX+CIY*RNY+CIZ*RNZ
      RETURN
      END

!----------------------------------------------------------------------------

      SUBROUTINE GFOUT
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      PARAMETER (IRESRV=MAXMAT**2)
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     WRITE N.G.F. FILE
!
      COMPLEX*16 CM,SSX,ZRATI,ZRATI2,T1,ZARRAY,AR1,AR2,AR3,EPSCF,FRATI
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /CMB/ CM(IRESRV)
      COMMON /ANGL/ SALP(MAXSEG)
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      COMMON /GGRID/ AR1(11,10,4),AR2(17,5,4),AR3(9,8,4),EPSCF,DXA(3),DY
     1A(3),XSA(3),YSA(3),NXA(3),NYA(3)
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      COMMON /SMAT/ SSX(16,16)
      COMMON /ZLOAD/ ZARRAY(MAXSEG),NLOAD,NLODF
      COMMON/SAVE/EPSR,SIG,SCRWLT,SCRWRT,FMHZ,IP(2*MAXSEG),KCOM
      COMMON/CSAVE/COM(19,5)

	character ngfnam*80		! av12
	common /ngfnam/ ngfnam		! av12
!
!*** ERROR CORRECTED 11/20/89 *******************************
      DIMENSION T2X(1),T2Y(1),T2Z(1)
      EQUIVALENCE (T2X,ICON1),(T2Y,ICON2),(T2Z,ITAG)
!***
      DATA IGFL/20/

      OPEN(UNIT=IGFL,FILE=NGFNAM,
     &FORM='UNFORMATTED',STATUS='UNKNOWN')	! av12

      NEQ=N+2*M
      NPEQ=NP+2*MP
      NOP=NEQ/NPEQ
      WRITE (IGFL) N,NP,M,MP,WLAM,FMHZ,IPSYM,KSYMP,IPERF,NRADL,EPSR,
     1SIG,SCRWLT,SCRWRT,NLOAD,KCOM
      IF (N.EQ.0) GO TO 1
      WRITE (IGFL) (X(I),I=1,N),(Y(I),I=1,N),(Z(I),I=1,N)
      WRITE (IGFL) (SI(I),I=1,N),(BI(I),I=1,N),(ALP(I),I=1,N)
      WRITE (IGFL) (BET(I),I=1,N),(SALP(I),I=1,N)
      WRITE (IGFL) (ICON1(I),I=1,N),(ICON2(I),I=1,N)
      WRITE (IGFL) (ITAG(I),I=1,N)
      IF (NLOAD.GT.0) WRITE (IGFL) (ZARRAY(I),I=1,N)
1     IF (M.EQ.0) GO TO 2
      J=LD-M+1
      WRITE (IGFL) (X(I),I=J,LD),(Y(I),I=J,LD),(Z(I),I=J,LD)
      WRITE (IGFL) (SI(I),I=J,LD),(BI(I),I=J,LD),(ALP(I),I=J,LD)
      WRITE (IGFL) (BET(I),I=J,LD),(SALP(I),I=J,LD)
!
!*** ERROR CORRECTED 11/20/89 *******************************
                                                             
      WRITE (IGFL) (T2X(I),I=J,LD),(T2Y(I),I=J,LD)
      WRITE (IGFL) (T2Z(I),I=J,LD)
!      WRITE (IGFL) (ICON1(I),I=J,LD),(ICON2(I),I=J,LD)
!      WRITE (IGFL) (ITAG(I),I=J,LD)
!
2     WRITE (IGFL) ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT
      IF (IPERF.EQ.2) WRITE (IGFL) AR1,AR2,AR3,EPSCF,DXA,DYA,XSA,YSA,NXA
     1,NYA
      IF (NOP.GT.1) WRITE (IGFL) ((SSX(I,J),I=1,NOP),J=1,NOP)
      WRITE (IGFL) (IP(I),I=1,NEQ),COM
      IF (ICASE.GT.2) GO TO 3
      IOUT=NEQ*NPEQ
      WRITE (IGFL) (CM(I),I=1,IOUT)
      GO TO 12
3     IF (ICASE.NE.4) GO TO 5
      REWIND 13
      I=NPEQ*NPEQ
      DO 4 K=1,NOP
      READ (13) (CM(J),J=1,I)
4     WRITE (IGFL) (CM(J),J=1,I)
      REWIND 13
      GO TO 12
5     REWIND 13
      REWIND 14
      IF (ICASE.EQ.5) GO TO 8
      IOUT=NPBLK*NEQ*2
      DO 6 I=1,NBLOKS
      CALL BLCKIN (CM,13,1,IOUT,1,201)
6     CALL BLCKOT (CM,IGFL,1,IOUT,1,202)
      DO 7 I=1,NBLOKS
      CALL BLCKIN (CM,14,1,IOUT,1,203)
7     CALL BLCKOT (CM,IGFL,1,IOUT,1,204)
      GO TO 12
8     IOUT=NPSYM*NPEQ*2
      DO 11 IOP=1,NOP
      DO 9 I=1,NBLSYM
      CALL BLCKIN (CM,13,1,IOUT,1,205)
9     CALL BLCKOT (CM,IGFL,1,IOUT,1,206)
      DO 10 I=1,NBLSYM
      CALL BLCKIN (CM,14,1,IOUT,1,207)
10    CALL BLCKOT (CM,IGFL,1,IOUT,1,208)
11    CONTINUE
      REWIND 13
      REWIND 14
12    REWIND IGFL
      WRITE(3,13)  IGFL,IMAT
      RETURN
!
13    FORMAT (///,44H ****NUMERICAL GREEN'S FUNCTION FILE ON TAPE,I3,5H
     1****,/,5X,16HMATRIX STORAGE -,I7,16H COMPLEX NUMBERS,///)
      END
!----------------------------------------------------------------------------

      SUBROUTINE GH (ZK,HR,HI)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     INTEGRAND FOR H FIELD OF A WIRE
      COMMON /TMH/ ZPK,RHKS
      RS=ZK-ZPK
      RS=RHKS+RS*RS
      R=SQRT(RS)
      CKR=COS(R)
      SKR=SIN(R)
      RR2=1./RS
      RR3=RR2/R
      HR=SKR*RR2+CKR*RR3
      HI=CKR*RR2-SKR*RR3
      RETURN
      END

!----------------------------------------------------------------------------

      SUBROUTINE GWAVE (ERV,EZV,ERH,EZH,EPH)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     GWAVE COMPUTES THE ELECTRIC FIELD, INCLUDING GROUND WAVE, OF A
!     CURRENT ELEMENT OVER A GROUND PLANE USING FORMULAS OF K.A. NORTON
!     (PROC. IRE, SEPT., 1937, PP.1203,1236.)
!
      COMPLEX*16 FJ,TPJ,U2,U,RK1,RK2,T1,T2,T3,T4,P1,RV,OMR,W,F,Q1,RH,V,G
     -,XR1,XR2,X1,X2,X3,X4,X5,X6,X7,EZV,ERV,EZH,ERH,EPH,XX1,XX2,ECON,
     -FBAR

      COMMON /GWAV/ U,U2,XX1,XX2,R1,R2,ZMH,ZPH
      DIMENSION FJX(2), TPJX(2), ECONX(2)
      EQUIVALENCE (FJ,FJX), (TPJ,TPJX), (ECON,ECONX)
	DATA FJX/0.,1./,TPJX/0.,6.283185308D+0/
      DATA ECONX/0.,-188.367/
      SPPP=ZMH/R1
      SPPP2=SPPP*SPPP
      CPPP2=1.-SPPP2
      IF (CPPP2.LT.1.D-20) CPPP2=1.D-20
      CPPP=SQRT(CPPP2)
      SPP=ZPH/R2
      SPP2=SPP*SPP
      CPP2=1.-SPP2
      IF (CPP2.LT.1.D-20) CPP2=1.D-20
      CPP=SQRT(CPP2)
      RK1=-TPJ*R1
      RK2=-TPJ*R2
      T1=1.-U2*CPP2
      T2=SQRT(T1)
      T3=(1.-1./RK1)/RK1
      T4=(1.-1./RK2)/RK2
      P1=RK2*U2*T1/(2.*CPP2)
      RV=(SPP-U*T2)/(SPP+U*T2)
      OMR=1.-RV
      W=1./OMR
      W=(4.,0.)*P1*W*W
      F=FBAR(W)
      Q1=RK2*T1/(2.*U2*CPP2)
      RH=(T2-U*SPP)/(T2+U*SPP)
      V=1./(1.+RH)
      V=(4.,0.)*Q1*V*V
      G=FBAR(V)
      XR1=XX1/R1
      XR2=XX2/R2
      X1=CPPP2*XR1
      X2=RV*CPP2*XR2
      X3=OMR*CPP2*F*XR2
      X4=U*T2*SPP*2.*XR2/RK2
      X5=XR1*T3*(1.-3.*SPPP2)
      X6=XR2*T4*(1.-3.*SPP2)
      EZV=(X1+X2+X3-X4-X5-X6)*ECON
      X1=SPPP*CPPP*XR1
      X2=RV*SPP*CPP*XR2
      X3=CPP*OMR*U*T2*F*XR2
      X4=SPP*CPP*OMR*XR2/RK2
      X5=3.*SPPP*CPPP*T3*XR1
      X6=CPP*U*T2*OMR*XR2/RK2*.5
      X7=3.*SPP*CPP*T4*XR2
      ERV=-(X1+X2-X3+X4-X5+X6-X7)*ECON
      EZH=-(X1-X2+X3-X4-X5-X6+X7)*ECON
      X1=SPPP2*XR1
      X2=RV*SPP2*XR2
      X4=U2*T1*OMR*F*XR2
      X5=T3*(1.-3.*CPPP2)*XR1
      X6=T4*(1.-3.*CPP2)*(1.-U2*(1.+RV)-U2*OMR*F)*XR2
      X7=U2*CPP2*OMR*(1.-1./RK2)*(F*(U2*T1-SPP2-1./RK2)+1./RK2)*XR2
      ERH=(X1-X2-X4-X5+X6+X7)*ECON
      X1=XR1
      X2=RH*XR2
      X3=(RH+1.)*G*XR2
      X4=T3*XR1
      X5=T4*(1.-U2*(1.+RV)-U2*OMR*F)*XR2
      X6=.5*U2*OMR*(F*(U2*T1-SPP2-1./RK2)+1./RK2)*XR2/RK2
      EPH=-(X1-X2+X3-X4+X5+X6)*ECON
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE GX (ZZ,RH,XK,GZ,GZP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     SEGMENT END CONTRIBUTIONS FOR THIN WIRE APPROX.
      COMPLEX*16 GZ,GZP
      R2=ZZ*ZZ+RH*RH
      R=SQRT(R2)
      RK=XK*R
      GZ=DCMPLX(COS(RK),-SIN(RK))/R
      GZP=-DCMPLX(1.D+0,RK)*GZ/R2
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE GXX (ZZ,RH,A,A2,XK,IRA,G1,G1P,G2,G2P,G3,GZP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     SEGMENT END CONTRIBUTIONS FOR EXT. THIN WIRE APPROX.
      COMPLEX*16 GZ,C1,C2,C3,G1,G1P,G2,G2P,G3,GZP
      R2=ZZ*ZZ+RH*RH
      R=SQRT(R2)
      R4=R2*R2
      RK=XK*R
      RK2=RK*RK
      RH2=RH*RH
      T1=.25*A2*RH2/R4
      T2=.5*A2/R2
      C1=DCMPLX(1.D+0,RK)
      C2=3.*C1-RK2
      C3=DCMPLX(6.D+0,RK)*RK2-15.*C1
      GZ=DCMPLX(COS(RK),-SIN(RK))/R
      G2=GZ*(1.+T1*C2)
      G1=G2-T2*C1*GZ
      GZ=GZ/R2
      G2P=GZ*(T1*C3-C1)
      GZP=T2*C2*GZ
      G3=G2P+GZP
      G1P=G3*ZZ
      IF (IRA.EQ.1) GO TO 2
      G3=(G3+GZP)*RH
      GZP=-ZZ*C1*GZ
      IF (RH.GT.1.D-10) GO TO 1
      G2=0.
      G2P=0.
      RETURN
1     G2=G2/RH
      G2P=G2P*ZZ/RH
      RETURN
2     T2=.5*A
      G2=-T2*C1*GZ
      G2P=T2*GZ*C2/R2
      G3=RH2*G2P-A*GZ*C1
      G2P=G2P*ZZ
      GZP=-ZZ*C1*GZ
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE HELIX(S,HL,A1,B1,A2,B2,RAD,NS,ITG)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     SUBROUTINE HELIX GENERATES SEGMENT GEOMETRY DATA FOR A HELIX OF NS
!     SEGMENTS
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      DIMENSION X2(1),Y2(1),Z2(1)
      EQUIVALENCE (X2(1),SI(1)), (Y2(1),ALP(1)), (Z2(1),BET(1))
      DATA PI/3.1415926D+0/
      IST=N+1
      N=N+NS
      NP=N
      MP=M
      IPSYM=0
      IF(NS.LT.1) RETURN
      TURNS=ABS(HL/S)
      ZINC=ABS(HL/NS)
      Z(IST)=0.
      DO 25 I=IST,N
      BI(I)=RAD
      ITAG(I)=ITG
      IF(I.NE.IST) Z(I)=Z(I-1)+ZINC
      Z2(I)=Z(I)+ZINC
      IF(A2.NE.A1) GO TO 10
      IF(B1.EQ.0) B1=A1
      X(I)=A1*COS(2.*PI*Z(I)/S)
      Y(I)=B1*SIN(2.*PI*Z(I)/S)
      X2(I)=A1*COS(2.*PI*Z2(I)/S)
      Y2(I)=B1*SIN(2.*PI*Z2(I)/S)
      GO TO 20
10    IF(B2.EQ.0) B2=A2
      X(I)=(A1+(A2-A1)*Z(I)/ABS(HL))*COS(2.*PI*Z(I)/S)
      Y(I)=(B1+(B2-B1)*Z(I)/ABS(HL))*SIN(2.*PI*Z(I)/S)
      X2(I)=(A1+(A2-A1)*Z2(I)/ABS(HL))*COS(2.*PI*Z2(I)/S)
      Y2(I)=(B1+(B2-B1)*Z2(I)/ABS(HL))*SIN(2.*PI*Z2(I)/S)
20    IF(HL.GT.0) GO TO 25
      COPY=X(I)
      X(I)=Y(I)
      Y(I)=COPY
      COPY=X2(I)
      X2(I)=Y2(I)
      Y2(I)=COPY
25    CONTINUE
      IF(A2.EQ.A1) GO TO 21
      SANGLE=ATAN(A2/(ABS(HL)+(ABS(HL)*A1)/(A2-A1)))
      WRITE(3,104)  SANGLE
104   FORMAT(5X,'THE CONE ANGLE OF THE SPIRAL IS',F10.4)
      RETURN
21    IF(A1.NE.B1) GO TO 30
      HDIA=2.*A1
      TURN=HDIA*PI
      PITCH=ATAN(S/(PI*HDIA))
      TURN=TURN/COS(PITCH)
      PITCH=180.*PITCH/PI
      GO TO 40
30    IF(A1.LT.B1) GO TO 34
      HMAJ=2.*A1
      HMIN=2.*B1
      GO TO 35
34    HMAJ=2.*B1
      HMIN=2.*A1
35    HDIA=SQRT((HMAJ**2+HMIN**2)/2*HMAJ)
      TURN=2.*PI*HDIA
      PITCH=(180./PI)*ATAN(S/(PI*HDIA))
40    WRITE(3,105) PITCH,TURN
105   FORMAT(5X,'THE PITCH ANGLE IS',F10.4/5X,'THE LENGTH OF WIRE/TURN I
     1S',F10.4)
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE HFK (EL1,EL2,RHK,ZPKX,SGR,SGI)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     HFK COMPUTES THE H FIELD OF A UNIFORM CURRENT FILAMENT BY
!     NUMERICAL INTEGRATION
      COMMON /TMH/ ZPK,RHKS
      DATA NX,NM,NTS,RX/1,65536,4,1.D-4/
      ZPK=ZPKX
      RHKS=RHK*RHK
      Z=EL1
      ZE=EL2
      S=ZE-Z
      EP=S/(10.*NM)
      ZEND=ZE-EP
      SGR=0.0
      SGI=0.0
      NS=NX
      NT=0
      CALL GH (Z,G1R,G1I)
1     DZ=S/NS
      ZP=Z+DZ
      IF (ZP-ZE) 3,3,2
2     DZ=ZE-Z
      IF (ABS(DZ)-EP) 17,17,3
3     DZOT=DZ*.5
      ZP=Z+DZOT
      CALL GH (ZP,G3R,G3I)
      ZP=Z+DZ
      CALL GH (ZP,G5R,G5I)
4     T00R=(G1R+G5R)*DZOT
      T00I=(G1I+G5I)*DZOT
      T01R=(T00R+DZ*G3R)*0.5
      T01I=(T00I+DZ*G3I)*0.5
      T10R=(4.0*T01R-T00R)/3.0
      T10I=(4.0*T01I-T00I)/3.0
      CALL TEST (T01R,T10R,TE1R,T01I,T10I,TE1I,0.D0)
      IF (TE1I-RX) 5,5,6
5     IF (TE1R-RX) 8,8,6
6     ZP=Z+DZ*0.25
      CALL GH (ZP,G2R,G2I)
      ZP=Z+DZ*0.75
      CALL GH (ZP,G4R,G4I)
      T02R=(T01R+DZOT*(G2R+G4R))*0.5
      T02I=(T01I+DZOT*(G2I+G4I))*0.5
      T11R=(4.0*T02R-T01R)/3.0
      T11I=(4.0*T02I-T01I)/3.0
      T20R=(16.0*T11R-T10R)/15.0
      T20I=(16.0*T11I-T10I)/15.0
      CALL TEST (T11R,T20R,TE2R,T11I,T20I,TE2I,0.D0)
      IF (TE2I-RX) 7,7,14
7     IF (TE2R-RX) 9,9,14
8     SGR=SGR+T10R
      SGI=SGI+T10I
      NT=NT+2
      GO TO 10
9     SGR=SGR+T20R
      SGI=SGI+T20I
      NT=NT+1
10    Z=Z+DZ
      IF (Z-ZEND) 11,17,17
11    G1R=G5R
      G1I=G5I
      IF (NT-NTS) 1,12,12
12    IF (NS-NX) 1,1,13
13    NS=NS/2
      NT=1
      GO TO 1
14    NT=0
      IF (NS-NM) 16,15,15
15    WRITE(3,18)  Z
      GO TO 9
16    NS=NS*2
      DZ=S/NS
      DZOT=DZ*0.5
      G5R=G3R
      G5I=G3I
      G3R=G2R
      G3I=G2I
      GO TO 4
17    CONTINUE
      SGR=SGR*RHK*.5
      SGI=SGI*RHK*.5
      RETURN
!
18    FORMAT (24H STEP SIZE LIMITED AT Z=,F10.5)
      END
!----------------------------------------------------------------------------

      SUBROUTINE HINTG (XI,YI,ZI)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     HINTG COMPUTES THE H FIELD OF A PATCH CURRENT
      COMPLEX*16 EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC,ZRATI,ZRATI2,GAM
     1,F1X,F1Y,F1Z,F2X,F2Y,F2Z,RRV,RRH,T1,FRATI
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      EQUIVALENCE (T1XJ,CABJ), (T1YJ,SABJ), (T1ZJ,SALPJ), (T2XJ,B), (T2Y
     1J,IND1), (T2ZJ,IND2)
      DATA FPI/12.56637062D+0/,TP/6.283185308D+0/
      RX=XI-XJ
      RY=YI-YJ
      RFL=-1.
      EXK=(0.,0.)
      EYK=(0.,0.)
      EZK=(0.,0.)
      EXS=(0.,0.)
      EYS=(0.,0.)
      EZS=(0.,0.)
      DO 5 IP=1,KSYMP
      RFL=-RFL
      RZ=ZI-ZJ*RFL
      RSQ=RX*RX+RY*RY+RZ*RZ
      IF (RSQ.LT.1.D-20) GO TO 5
      R=SQRT(RSQ)
      RK=TP*R
      CR=COS(RK)
      SR=SIN(RK)
      GAM=-(DCMPLX(CR,-SR)+RK*DCMPLX(SR,CR))/(FPI*RSQ*R)*S
      EXC=GAM*RX
      EYC=GAM*RY
      EZC=GAM*RZ
      T1ZR=T1ZJ*RFL
      T2ZR=T2ZJ*RFL
      F1X=EYC*T1ZR-EZC*T1YJ
      F1Y=EZC*T1XJ-EXC*T1ZR
      F1Z=EXC*T1YJ-EYC*T1XJ
      F2X=EYC*T2ZR-EZC*T2YJ
      F2Y=EZC*T2XJ-EXC*T2ZR
      F2Z=EXC*T2YJ-EYC*T2XJ
      IF (IP.EQ.1) GO TO 4
      IF (IPERF.NE.1) GO TO 1
      F1X=-F1X
      F1Y=-F1Y
      F1Z=-F1Z
      F2X=-F2X
      F2Y=-F2Y
      F2Z=-F2Z
      GO TO 4
1     XYMAG=SQRT(RX*RX+RY*RY)
      IF (XYMAG.GT.1.D-6) GO TO 2
      PX=0.
      PY=0.
      CTH=1.
      RRV=(1.,0.)
      GO TO 3
2     PX=-RY/XYMAG
      PY=RX/XYMAG
      CTH=RZ/R
      RRV=SQRT(1.-ZRATI*ZRATI*(1.-CTH*CTH))
3     RRH=ZRATI*CTH
      RRH=(RRH-RRV)/(RRH+RRV)
      RRV=ZRATI*RRV
      RRV=-(CTH-RRV)/(CTH+RRV)
      GAM=(F1X*PX+F1Y*PY)*(RRV-RRH)
      F1X=F1X*RRH+GAM*PX
      F1Y=F1Y*RRH+GAM*PY
      F1Z=F1Z*RRH
      GAM=(F2X*PX+F2Y*PY)*(RRV-RRH)
      F2X=F2X*RRH+GAM*PX
      F2Y=F2Y*RRH+GAM*PY
      F2Z=F2Z*RRH
4     EXK=EXK+F1X
      EYK=EYK+F1Y
      EZK=EZK+F1Z
      EXS=EXS+F2X
      EYS=EYS+F2Y
      EZS=EZS+F2Z
5     CONTINUE
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE HSFLD (XI,YI,ZI,AI)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     HSFLD COMPUTES THE H FIELD FOR CONSTANT, SINE, AND COSINE CURRENT
!     ON A SEGMENT INCLUDING GROUND EFFECTS.
      COMPLEX*16 EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC,ZRATI,ZRATI2,T1
     1,HPK,HPS,HPC,QX,QY,QZ,RRV,RRH,ZRATX,FRATI
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      DATA ETA/376.73/
      XIJ=XI-XJ
      YIJ=YI-YJ
      RFL=-1.
      DO 7 IP=1,KSYMP
      RFL=-RFL
      SALPR=SALPJ*RFL
      ZIJ=ZI-RFL*ZJ
      ZP=XIJ*CABJ+YIJ*SABJ+ZIJ*SALPR
      RHOX=XIJ-CABJ*ZP
      RHOY=YIJ-SABJ*ZP
      RHOZ=ZIJ-SALPR*ZP
      RH=SQRT(RHOX*RHOX+RHOY*RHOY+RHOZ*RHOZ+AI*AI)
      IF (RH.GT.1.D-10) GO TO 1
      EXK=0.
      EYK=0.
      EZK=0.
      EXS=0.
      EYS=0.
      EZS=0.
      EXC=0.
      EYC=0.
      EZC=0.
      GO TO 7
1     RHOX=RHOX/RH
      RHOY=RHOY/RH
      RHOZ=RHOZ/RH
      PHX=SABJ*RHOZ-SALPR*RHOY
      PHY=SALPR*RHOX-CABJ*RHOZ
      PHZ=CABJ*RHOY-SABJ*RHOX
      CALL HSFLX (S,RH,ZP,HPK,HPS,HPC)
      IF (IP.NE.2) GO TO 6
      IF (IPERF.EQ.1) GO TO 5
      ZRATX=ZRATI
      RMAG=SQRT(ZP*ZP+RH*RH)
      XYMAG=SQRT(XIJ*XIJ+YIJ*YIJ)
!
!     SET PARAMETERS FOR RADIAL WIRE GROUND SCREEN.
!
      IF (NRADL.EQ.0) GO TO 2
      XSPEC=(XI*ZJ+ZI*XJ)/(ZI+ZJ)
      YSPEC=(YI*ZJ+ZI*YJ)/(ZI+ZJ)
      RHOSPC=SQRT(XSPEC*XSPEC+YSPEC*YSPEC+T2*T2)
      IF (RHOSPC.GT.SCRWL) GO TO 2
      RRV=T1*RHOSPC*LOG(RHOSPC/T2)
      ZRATX=(RRV*ZRATI)/(ETA*ZRATI+RRV)
2     IF (XYMAG.GT.1.D-6) GO TO 3
!
!     CALCULATION OF REFLECTION COEFFICIENTS WHEN GROUND IS SPECIFIED.
!
      PX=0.
      PY=0.
      CTH=1.
      RRV=(1.,0.)
      GO TO 4
3     PX=-YIJ/XYMAG
      PY=XIJ/XYMAG
      CTH=ZIJ/RMAG
      RRV=SQRT(1.-ZRATX*ZRATX*(1.-CTH*CTH))
4     RRH=ZRATX*CTH
      RRH=-(RRH-RRV)/(RRH+RRV)
      RRV=ZRATX*RRV
      RRV=(CTH-RRV)/(CTH+RRV)
      QY=(PHX*PX+PHY*PY)*(RRV-RRH)
      QX=QY*PX+PHX*RRH
      QY=QY*PY+PHY*RRH
      QZ=PHZ*RRH
      EXK=EXK-HPK*QX
      EYK=EYK-HPK*QY
      EZK=EZK-HPK*QZ
      EXS=EXS-HPS*QX
      EYS=EYS-HPS*QY
      EZS=EZS-HPS*QZ
      EXC=EXC-HPC*QX
      EYC=EYC-HPC*QY
      EZC=EZC-HPC*QZ
      GO TO 7
5     EXK=EXK-HPK*PHX
      EYK=EYK-HPK*PHY
      EZK=EZK-HPK*PHZ
      EXS=EXS-HPS*PHX
      EYS=EYS-HPS*PHY
      EZS=EZS-HPS*PHZ
      EXC=EXC-HPC*PHX
      EYC=EYC-HPC*PHY
      EZC=EZC-HPC*PHZ
      GO TO 7
6     EXK=HPK*PHX
      EYK=HPK*PHY
      EZK=HPK*PHZ
      EXS=HPS*PHX
      EYS=HPS*PHY
      EZS=HPS*PHZ
      EXC=HPC*PHX
      EYC=HPC*PHY
      EZC=HPC*PHZ
7     CONTINUE
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE HSFLX (S,RH,ZPX,HPK,HPS,HPC)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     CALCULATES H FIELD OF SINE COSINE, AND CONSTANT CURRENT OF SEGMENT
      COMPLEX*16 FJ,FJK,EKR1,EKR2,T1,T2,CONS,HPS,HPC,HPK
      DIMENSION FJX(2), FJKX(2)
      EQUIVALENCE (FJ,FJX), (FJK,FJKX)
      DATA TP/6.283185308D+0/,FJX/0.,1./,FJKX/0.,-6.283185308D+0/
      DATA PI8/25.13274123D+0/
      IF (RH.LT.1.D-10) GO TO 6
      IF (ZPX.LT.0.) GO TO 1
      ZP=ZPX
      HSS=1.
      GO TO 2
1     ZP=-ZPX
      HSS=-1.
2     DH=.5*S
      Z1=ZP+DH
      Z2=ZP-DH
      IF (Z2.LT.1.D-7) GO TO 3
      RHZ=RH/Z2
      GO TO 4
3     RHZ=1.
4     DK=TP*DH
      CDK=COS(DK)
      SDK=SIN(DK)
      CALL HFK (-DK,DK,RH*TP,ZP*TP,HKR,HKI)
      HPK=DCMPLX(HKR,HKI)
      IF (RHZ.LT.1.D-3) GO TO 5
      RH2=RH*RH
      R1=SQRT(RH2+Z1*Z1)
      R2=SQRT(RH2+Z2*Z2)
      EKR1=EXP(FJK*R1)
      EKR2=EXP(FJK*R2)
      T1=Z1*EKR1/R1
      T2=Z2*EKR2/R2
      HPS=(CDK*(EKR2-EKR1)-FJ*SDK*(T2+T1))*HSS
      HPC=-SDK*(EKR2+EKR1)-FJ*CDK*(T2-T1)
      CONS=-FJ/(2.*TP*RH)
      HPS=CONS*HPS
      HPC=CONS*HPC
      RETURN
5     EKR1=DCMPLX(CDK,SDK)/(Z2*Z2)
      EKR2=DCMPLX(CDK,-SDK)/(Z1*Z1)
      T1=TP*(1./Z1-1./Z2)
      T2=EXP(FJK*ZP)*RH/PI8
      HPS=T2*(T1+(EKR1+EKR2)*SDK)*HSS
      HPC=T2*(-FJ*T1+(EKR1-EKR2)*CDK)
      RETURN
6     HPS=(0.,0.)
      HPC=(0.,0.)
      HPK=(0.,0.)
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE INTRP (X,Y,F1,F2,F3,F4)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     INTRP USES BIVARIATE CUBIC INTERPOLATION TO OBTAIN THE VALUES OF
!     4 FUNCTIONS AT THE POINT (X,Y).
!
      COMPLEX*16 F1,F2,F3,F4,A,B,C,D,FX1,FX2,FX3,FX4,P1,P2,P3,P4,A11,A12
     1,A13,A14,A21,A22,A23,A24,A31,A32,A33,A34,A41,A42,A43,A44,B11,B12
     2,B13,B14,B21,B22,B23,B24,B31,B32,B33,B34,B41,B42,B43,B44,C11,C12
     3,C13,C14,C21,C22,C23,C24,C31,C32,C33,C34,C41,C42,C43,C44,D11,D12
     4,D13,D14,D21,D22,D23,D24,D31,D32,D33,D34,D41,D42,D43,D44
      COMPLEX*16 AR1,AR2,AR3,ARL1,ARL2,ARL3,EPSCF
      COMMON /GGRID/ AR1(11,10,4),AR2(17,5,4),AR3(9,8,4),EPSCF,DXA(3),DY
     1A(3),XSA(3),YSA(3),NXA(3),NYA(3)
      DIMENSION NDA(3), NDPA(3)
      DIMENSION A(4,4), B(4,4), C(4,4), D(4,4), ARL1(1), ARL2(1), ARL3(1
     1)
      EQUIVALENCE (A(1,1),A11), (A(1,2),A12), (A(1,3),A13), (A(1,4),A14)
      EQUIVALENCE (A(2,1),A21), (A(2,2),A22), (A(2,3),A23), (A(2,4),A24)
      EQUIVALENCE (A(3,1),A31), (A(3,2),A32), (A(3,3),A33), (A(3,4),A34)
      EQUIVALENCE (A(4,1),A41), (A(4,2),A42), (A(4,3),A43), (A(4,4),A44)
      EQUIVALENCE (B(1,1),B11), (B(1,2),B12), (B(1,3),B13), (B(1,4),B14)
      EQUIVALENCE (B(2,1),B21), (B(2,2),B22), (B(2,3),B23), (B(2,4),B24)
      EQUIVALENCE (B(3,1),B31), (B(3,2),B32), (B(3,3),B33), (B(3,4),B34)
      EQUIVALENCE (B(4,1),B41), (B(4,2),B42), (B(4,3),B43), (B(4,4),B44)
      EQUIVALENCE (C(1,1),C11), (C(1,2),C12), (C(1,3),C13), (C(1,4),C14)
      EQUIVALENCE (C(2,1),C21), (C(2,2),C22), (C(2,3),C23), (C(2,4),C24)
      EQUIVALENCE (C(3,1),C31), (C(3,2),C32), (C(3,3),C33), (C(3,4),C34)
      EQUIVALENCE (C(4,1),C41), (C(4,2),C42), (C(4,3),C43), (C(4,4),C44)
      EQUIVALENCE (D(1,1),D11), (D(1,2),D12), (D(1,3),D13), (D(1,4),D14)
      EQUIVALENCE (D(2,1),D21), (D(2,2),D22), (D(2,3),D23), (D(2,4),D24)
      EQUIVALENCE (D(3,1),D31), (D(3,2),D32), (D(3,3),D33), (D(3,4),D34)
      EQUIVALENCE (D(4,1),D41), (D(4,2),D42), (D(4,3),D43), (D(4,4),D44)
      EQUIVALENCE (ARL1,AR1), (ARL2,AR2), (ARL3,AR3), (XS2,XSA(2)), (YS3
     1,YSA(3))
      DATA IXS,IYS,IGRS/-10,-10,-10/,DX,DY,XS,YS/1.,1.,0.,0./
      DATA NDA/11,17,9/,NDPA/110,85,72/,IXEG,IYEG/0,0/
      IF (X.LT.XS.OR.Y.LT.YS) GO TO 1
      IX=INT((X-XS)/DX)+1
      IY=INT((Y-YS)/DY)+1
!
!     IF POINT LIES IN SAME 4 BY 4 POINT REGION AS PREVIOUS POINT, OLD
!     VALUES ARE REUSED
!
      IF (IX.LT.IXEG.OR.IY.LT.IYEG) GO TO 1
      IF (IABS(IX-IXS).LT.2.AND.IABS(IY-IYS).LT.2) GO TO 12
!
!     DETERMINE CORRECT GRID AND GRID REGION
!
1     IF (X.GT.XS2) GO TO 2
      IGR=1
      GO TO 3
2     IGR=2
      IF (Y.GT.YS3) IGR=3
3     IF (IGR.EQ.IGRS) GO TO 4
      IGRS=IGR
      DX=DXA(IGRS)
      DY=DYA(IGRS)
      XS=XSA(IGRS)
      YS=YSA(IGRS)
      NXM2=NXA(IGRS)-2
      NYM2=NYA(IGRS)-2
      NXMS=((NXM2+1)/3)*3+1
      NYMS=((NYM2+1)/3)*3+1
      ND=NDA(IGRS)
      NDP=NDPA(IGRS)
      IX=INT((X-XS)/DX)+1
      IY=INT((Y-YS)/DY)+1
4     IXS=((IX-1)/3)*3+2
      IF (IXS.LT.2) IXS=2
      IXEG=-10000
      IF (IXS.LE.NXM2) GO TO 5
      IXS=NXM2
      IXEG=NXMS
5     IYS=((IY-1)/3)*3+2
      IF (IYS.LT.2) IYS=2
      IYEG=-10000
      IF (IYS.LE.NYM2) GO TO 6
      IYS=NYM2
      IYEG=NYMS
!
!     COMPUTE COEFFICIENTS OF 4 CUBIC POLYNOMIALS IN X FOR THE 4 GRID
!     VALUES OF Y FOR EACH OF THE 4 FUNCTIONS
!
6     IADZ=IXS+(IYS-3)*ND-NDP
      DO 11 K=1,4
      IADZ=IADZ+NDP
      IADD=IADZ
      DO 11 I=1,4
      IADD=IADD+ND
      GO TO (7,8,9), IGRS
!     P1=AR1(IXS-1,IYS-2+I,K)
7     P1=ARL1(IADD-1)
      P2=ARL1(IADD)
      P3=ARL1(IADD+1)
      P4=ARL1(IADD+2)
      GO TO 10
8     P1=ARL2(IADD-1)
      P2=ARL2(IADD)
      P3=ARL2(IADD+1)
      P4=ARL2(IADD+2)
      GO TO 10
9     P1=ARL3(IADD-1)
      P2=ARL3(IADD)
      P3=ARL3(IADD+1)
      P4=ARL3(IADD+2)
10    A(I,K)=(P4-P1+3.*(P2-P3))*.1666666667D+0
      B(I,K)=(P1-2.*P2+P3)*.5
      C(I,K)=P3-(2.*P1+3.*P2+P4)*.1666666667D+0
11    D(I,K)=P2
      XZ=(IXS-1)*DX+XS
      YZ=(IYS-1)*DY+YS
!
!     EVALUATE POLYMOMIALS IN X AND THEN USE CUBIC INTERPOLATION IN Y
!     FOR EACH OF THE 4 FUNCTIONS.
!
12    XX=(X-XZ)/DX
      YY=(Y-YZ)/DY
      FX1=((A11*XX+B11)*XX+C11)*XX+D11
      FX2=((A21*XX+B21)*XX+C21)*XX+D21
      FX3=((A31*XX+B31)*XX+C31)*XX+D31
      FX4=((A41*XX+B41)*XX+C41)*XX+D41
      P1=FX4-FX1+3.*(FX2-FX3)
      P2=3.*(FX1-2.*FX2+FX3)
      P3=6.*FX3-2.*FX1-3.*FX2-FX4
      F1=((P1*YY+P2)*YY+P3)*YY*.1666666667D+0+FX2
      FX1=((A12*XX+B12)*XX+C12)*XX+D12
      FX2=((A22*XX+B22)*XX+C22)*XX+D22
      FX3=((A32*XX+B32)*XX+C32)*XX+D32
      FX4=((A42*XX+B42)*XX+C42)*XX+D42
      P1=FX4-FX1+3.*(FX2-FX3)
      P2=3.*(FX1-2.*FX2+FX3)
      P3=6.*FX3-2.*FX1-3.*FX2-FX4
      F2=((P1*YY+P2)*YY+P3)*YY*.1666666667D+0+FX2
      FX1=((A13*XX+B13)*XX+C13)*XX+D13
      FX2=((A23*XX+B23)*XX+C23)*XX+D23
      FX3=((A33*XX+B33)*XX+C33)*XX+D33
      FX4=((A43*XX+B43)*XX+C43)*XX+D43
      P1=FX4-FX1+3.*(FX2-FX3)
      P2=3.*(FX1-2.*FX2+FX3)
      P3=6.*FX3-2.*FX1-3.*FX2-FX4
      F3=((P1*YY+P2)*YY+P3)*YY*.1666666667D+0+FX2
      FX1=((A14*XX+B14)*XX+C14)*XX+D14
      FX2=((A24*XX+B24)*XX+C24)*XX+D24
      FX3=((A34*XX+B34)*XX+C34)*XX+D34
      FX4=((A44*XX+B44)*XX+C44)*XX+D44
      P1=FX4-FX1+3.*(FX2-FX3)
      P2=3.*(FX1-2.*FX2+FX3)
      P3=6.*FX3-2.*FX1-3.*FX2-FX4
      F4=((P1*YY+P2)*YY+P3)*YY*.1666666667D+0+FX2
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE INTX (EL1,EL2,B,IJ,SGR,SGI)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     INTX PERFORMS NUMERICAL INTEGRATION OF EXP(JKR)/R BY THE METHOD OF
!     VARIABLE INTERVAL WIDTH ROMBERG INTEGRATION.  THE INTEGRAND VALUE
!     IS SUPPLIED BY SUBROUTINE GF.
!
      DATA NX,NM,NTS,RX/1,65536,4,1.D-4/
      Z=EL1
      ZE=EL2
      IF (IJ.EQ.0) ZE=0.
      S=ZE-Z
      FNM=NM
      EP=S/(10.*FNM)
      ZEND=ZE-EP
      SGR=0.
      SGI=0.
      NS=NX
      NT=0
      CALL GF (Z,G1R,G1I)
1     FNS=NS
      DZ=S/FNS
      ZP=Z+DZ
      IF (ZP-ZE) 3,3,2
2     DZ=ZE-Z
      IF (ABS(DZ)-EP) 17,17,3
3     DZOT=DZ*.5
      ZP=Z+DZOT
      CALL GF (ZP,G3R,G3I)
      ZP=Z+DZ
      CALL GF (ZP,G5R,G5I)
4     T00R=(G1R+G5R)*DZOT
      T00I=(G1I+G5I)*DZOT
      T01R=(T00R+DZ*G3R)*0.5
      T01I=(T00I+DZ*G3I)*0.5
      T10R=(4.0*T01R-T00R)/3.0
      T10I=(4.0*T01I-T00I)/3.0
!
!     TEST CONVERGENCE OF 3 POINT ROMBERG RESULT.
!
      CALL TEST (T01R,T10R,TE1R,T01I,T10I,TE1I,0.D0)
      IF (TE1I-RX) 5,5,6
5     IF (TE1R-RX) 8,8,6
6     ZP=Z+DZ*0.25
      CALL GF (ZP,G2R,G2I)
      ZP=Z+DZ*0.75
      CALL GF (ZP,G4R,G4I)
      T02R=(T01R+DZOT*(G2R+G4R))*0.5
      T02I=(T01I+DZOT*(G2I+G4I))*0.5
      T11R=(4.0*T02R-T01R)/3.0
      T11I=(4.0*T02I-T01I)/3.0
      T20R=(16.0*T11R-T10R)/15.0
      T20I=(16.0*T11I-T10I)/15.0
!
!     TEST CONVERGENCE OF 5 POINT ROMBERG RESULT.
!
      CALL TEST (T11R,T20R,TE2R,T11I,T20I,TE2I,0.D0)
      IF (TE2I-RX) 7,7,14
7     IF (TE2R-RX) 9,9,14
8     SGR=SGR+T10R
      SGI=SGI+T10I
      NT=NT+2
      GO TO 10
9     SGR=SGR+T20R
      SGI=SGI+T20I
      NT=NT+1
10    Z=Z+DZ
      IF (Z-ZEND) 11,17,17
11    G1R=G5R
      G1I=G5I
      IF (NT-NTS) 1,12,12
12    IF (NS-NX) 1,1,13
!
!     DOUBLE STEP SIZE
!
13    NS=NS/2
      NT=1
      GO TO 1
14    NT=0
      IF (NS-NM) 16,15,15
15    WRITE(3,20)  Z
      GO TO 9
!
!     HALVE STEP SIZE
!
16    NS=NS*2
      FNS=NS
      DZ=S/FNS
      DZOT=DZ*0.5
      G5R=G3R
      G5I=G3I
      G3R=G2R
      G3I=G2I
      GO TO 4
17    CONTINUE
      IF (IJ) 19,18,19
!
!     ADD CONTRIBUTION OF NEAR SINGULARITY FOR DIAGONAL TERM
!
18    SGR=2.*(SGR+LOG((SQRT(B*B+S*S)+S)/B))
      SGI=2.*SGI
19    CONTINUE
      RETURN
!
20    FORMAT (24H STEP SIZE LIMITED AT Z=,F10.5)
      END
      FUNCTION ISEGNO (ITAGI,MX)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     ISEGNO RETURNS THE SEGMENT NUMBER OF THE MTH SEGMENT HAVING THE
!     TAG NUMBER ITAGI.  IF ITAGI=0 SEGMENT NUMBER M IS RETURNED.
!
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      IF (MX.GT.0) GO TO 1
      WRITE(3,6)
      STOP
1     ICNT=0
      IF (ITAGI.NE.0) GO TO 2
      ISEGNO=MX
      RETURN
2     IF (N.LT.1) GO TO 4
      DO 3 I=1,N
      IF (ITAG(I).NE.ITAGI) GO TO 3
      ICNT=ICNT+1
      IF (ICNT.EQ.MX) GO TO 5
3     CONTINUE
4     WRITE(3,7)  ITAGI
      STOP
5     ISEGNO=I
      RETURN
!
6     FORMAT (4X,91HCHECK DATA, PARAMETER SPECIFYING SEGMENT POSITION IN
     1 A GROUP OF EQUAL TAGS MUST NOT BE ZERO)
7     FORMAT (///,10X,26HNO SEGMENT HAS AN ITAG OF ,I5)
      END
!----------------------------------------------------------------------------

      SUBROUTINE LFACTR (A,NROW,IX1,IX2,IP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     LFACTR PERFORMS GAUSS-DOOLITTLE MANIPULATIONS ON THE TWO BLOCKS OF
!     THE TRANSPOSED MATRIX IN CORE STORAGE.  THE GAUSS-DOOLITTLE
!     ALGORITHM IS PRESENTED ON PAGES 411-416 OF A. RALSTON -- A FIRST
!     COURSE IN NUMERICAL ANALYSIS.  COMMENTS BELOW REFER TO COMMENTS IN
!     RALSTONS TEXT.
!
      COMPLEX*16 A,D,AJR
      INTEGER R,R1,R2,PJ,PR
      LOGICAL L1,L2,L3
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      COMMON /SCRATM/ D(2*MAXSEG)
      DIMENSION A(NROW,1), IP(NROW)
      IFLG=0
!
!     INITIALIZE R1,R2,J1,J2
!
      L1=IX1.EQ.1.AND.IX2.EQ.2
      L2=(IX2-1).EQ.IX1
      L3=IX2.EQ.NBLSYM
      IF (L1) GO TO 1
      GO TO 2
1     R1=1
      R2=2*NPSYM
      J1=1
      J2=-1
      GO TO 5
2     R1=NPSYM+1
      R2=2*NPSYM
      J1=(IX1-1)*NPSYM+1
      IF (L2) GO TO 3
      GO TO 4
3     J2=J1+NPSYM-2
      GO TO 5
4     J2=J1+NPSYM-1
5     IF (L3) R2=NPSYM+NLSYM
      DO 16 R=R1,R2
!
!     STEP 1
!
      DO 6 K=J1,NROW
      D(K)=A(K,R)
6     CONTINUE
!
!     STEPS 2 AND 3
!
      IF (L1.OR.L2) J2=J2+1
      IF (J1.GT.J2) GO TO 9
      IXJ=0
      DO 8 J=J1,J2
      IXJ=IXJ+1
      PJ=IP(J)
      AJR=D(PJ)
      A(J,R)=AJR
      D(PJ)=D(J)
      JP1=J+1
      DO 7 I=JP1,NROW
      D(I)=D(I)-A(I,IXJ)*AJR
7     CONTINUE
8     CONTINUE
9     CONTINUE
!
!     STEP 4
!
      J2P1=J2+1
      IF (L1.OR.L2) GO TO 11
      IF (NROW.LT.J2P1) GO TO 16
      DO 10 I=J2P1,NROW
      A(I,R)=D(I)
10    CONTINUE
      GO TO 16
11    DMAX=DREAL(D(J2P1)*DCONJG(D(J2P1)))
      IP(J2P1)=J2P1
      J2P2=J2+2
      IF (J2P2.GT.NROW) GO TO 13
      DO 12 I=J2P2,NROW
      ELMAG=DREAL(D(I)*DCONJG(D(I)))
      IF (ELMAG.LT.DMAX) GO TO 12
      DMAX=ELMAG
      IP(J2P1)=I
12    CONTINUE
13    CONTINUE
      IF (DMAX.LT.1.D-10) IFLG=1
      PR=IP(J2P1)
      A(J2P1,R)=D(PR)
      D(PR)=D(J2P1)
!
!     STEP 5
!
      IF (J2P2.GT.NROW) GO TO 15
      AJR=1./A(J2P1,R)
      DO 14 I=J2P2,NROW
      A(I,R)=D(I)*AJR
14    CONTINUE
15    CONTINUE
      IF (IFLG.EQ.0) GO TO 16
      WRITE(3,17)  J2,DMAX
      IFLG=0
16    CONTINUE
      RETURN
!
17    FORMAT (1H ,6HPIVOT(,I3,2H)=,1P,E16.8)
      END

!----------------------------------------------------------------------------

      SUBROUTINE LOAD (LDTYP,LDTAG,LDTAGF,LDTAGT,ZLR,ZLI,ZLC)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     LOAD CALCULATES THE IMPEDANCE OF SPECIFIED SEGMENTS FOR VARIOUS
!     TYPES OF LOADING
!
      COMPLEX*16 ZARRAY,ZT,TPCJ,ZINT
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ZLOAD/ ZARRAY(MAXSEG),NLOAD,NLODF
      DIMENSION LDTYP(1), LDTAG(1), LDTAGF(1), LDTAGT(1), ZLR(1), ZLI(1)
     1, ZLC(1), TPCJX(2)
      EQUIVALENCE (TPCJ,TPCJX)
      DATA TPCJX/0.,1.883698955D+9/
!
!     WRITE(3,HEADING)
!
      WRITE(3,25)
!
!     INITIALIZE D ARRAY, USED FOR TEMPORARY STORAGE OF LOADING
!     INFORMATION.
!
      DO 1 I=N2,N
 1    ZARRAY(I)=(0.,0.)
      IWARN=0
!
!     CYCLE OVER LOADING CARDS
!
      ISTEP=0
 2    ISTEP=ISTEP+1
      IF (ISTEP.LE.NLOAD) GO TO 5
      IF (IWARN.EQ.1) WRITE(3,26)
      IF (N1+2*M1.GT.0) GO TO 4
      NOP=N/NP
      IF (NOP.EQ.1) GO TO 4
      DO 3 I=1,NP
      ZT=ZARRAY(I)
      L1=I
      DO 3 L2=2,NOP
      L1=L1+NP
 3    ZARRAY(L1)=ZT
 4    RETURN
 5    IF (LDTYP(ISTEP).LE.5) GO TO 6
      WRITE(3,27)  LDTYP(ISTEP)
      STOP
 6    LDTAGS=LDTAG(ISTEP)
      JUMP=LDTYP(ISTEP)+1
      ICHK=0
!
!     SEARCH SEGMENTS FOR PROPER ITAGS
!
      L1=N2
      L2=N
      IF (LDTAGS.NE.0) GO TO 7
      IF (LDTAGF(ISTEP).EQ.0.AND.LDTAGT(ISTEP).EQ.0) GO TO 7
      L1=LDTAGF(ISTEP)
      L2=LDTAGT(ISTEP)
      IF (L1.GT.N1) GO TO 7
      WRITE(3,29)
      STOP
 7    DO 17 I=L1,L2
      IF (LDTAGS.EQ.0) GO TO 8
      IF (LDTAGS.NE.ITAG(I)) GO TO 17
      IF (LDTAGF(ISTEP).EQ.0) GO TO 8
      ICHK=ICHK+1
      IF (ICHK.GE.LDTAGF(ISTEP).AND.ICHK.LE.LDTAGT(ISTEP)) GO TO 9
      GO TO 17
 8    ICHK=1
!
!     CALCULATION OF LAMDA*IMPED. PER UNIT LENGTH, JUMP TO APPROPRIATE
!     SECTION FOR LOADING TYPE
!
 9    GO TO (10,11,12,13,14,15), JUMP
 10   ZT=ZLR(ISTEP)/SI(I)+TPCJ*ZLI(ISTEP)/(SI(I)*WLAM)
      IF (ABS(ZLC(ISTEP)).GT.1.D-20) ZT=ZT+WLAM/(TPCJ*SI(I)*ZLC(ISTEP))
      GO TO 16
 11   ZT=TPCJ*SI(I)*ZLC(ISTEP)/WLAM
      IF (ABS(ZLI(ISTEP)).GT.1.D-20) ZT=ZT+SI(I)*WLAM/(TPCJ*ZLI(ISTEP))
      IF (ABS(ZLR(ISTEP)).GT.1.D-20) ZT=ZT+SI(I)/ZLR(ISTEP)
      ZT=1./ZT
      GO TO 16
 12   ZT=ZLR(ISTEP)*WLAM+TPCJ*ZLI(ISTEP)
      IF (ABS(ZLC(ISTEP)).GT.1.D-20) ZT=ZT+1./(TPCJ*SI(I)*SI(I)*ZLC(ISTE
     1P))
      GO TO 16
 13   ZT=TPCJ*SI(I)*SI(I)*ZLC(ISTEP)
      IF (ABS(ZLI(ISTEP)).GT.1.D-20) ZT=ZT+1./(TPCJ*ZLI(ISTEP))
      IF (ABS(ZLR(ISTEP)).GT.1.D-20) ZT=ZT+1./(ZLR(ISTEP)*WLAM)
      ZT=1./ZT
      GO TO 16
 14   ZT=DCMPLX(ZLR(ISTEP),ZLI(ISTEP))/SI(I)
      GO TO 16
 15   ZT=ZINT(ZLR(ISTEP)*WLAM,BI(I))
 16   IF ((ABS(DREAL(ZARRAY(I)))+ABS(DIMAG(ZARRAY(I)))).GT.1.D-20)
     1IWARN=1
      ZARRAY(I)=ZARRAY(I)+ZT
 17   CONTINUE
      IF (ICHK.NE.0) GO TO 18
      WRITE(3,28)  LDTAGS
      STOP
!
!     PRINTING THE SEGMENT LOADING DATA, JUMP TO PROPER PRINT
!
 18   GO TO (19,20,21,22,23,24), JUMP
 19   CALL PRNT (LDTAGS,LDTAGF(ISTEP),LDTAGT(ISTEP),ZLR(ISTEP),ZLI(ISTEP
     1),ZLC(ISTEP),0.D0,0.D0,0.D0,' SERIES ')
      GO TO 2
 20   CALL PRNT (LDTAGS,LDTAGF(ISTEP),LDTAGT(ISTEP),ZLR(ISTEP),ZLI(ISTEP
     1),ZLC(ISTEP),0.D0,0.D0,0.D0,'PARALLEL')
      GO TO 2
 21   CALL PRNT (LDTAGS,LDTAGF(ISTEP),LDTAGT(ISTEP),ZLR(ISTEP),ZLI(ISTEP
     1),ZLC(ISTEP),0.D0,0.D0,0.D0,' SERIES (PER METER) ')
      GO TO 2
 22   CALL PRNT (LDTAGS,LDTAGF(ISTEP),LDTAGT(ISTEP),ZLR(ISTEP),ZLI(ISTEP
     1),ZLC(ISTEP),0.D0,0.D0,0.D0,'PARALLEL (PER METER)')
      GO TO 2
 23   CALL PRNT (LDTAGS,LDTAGF(ISTEP),LDTAGT(ISTEP),0.D0,0.D0,0.D0,
     &ZLR(ISTEP),ZLI(ISTEP),0.D0,'FIXED IMPEDANCE ')
      GO TO 2
 24   CALL PRNT (LDTAGS,LDTAGF(ISTEP),LDTAGT(ISTEP),0.D0,0.D0,0.D0,0.D0,
     &0.D0,ZLR(ISTEP),'  WIRE  ')
      GO TO 2
!
 25   FORMAT (//,7X,8HLOCATION,10X,10HRESISTANCE,3X,10HINDUCTANCE,2X,11H
     1CAPACITANCE,7X,16HIMPEDANCE (OHMS),5X,12HCONDUCTIVITY,4X,4HTYPE,/,
     24X,4HITAG,10H FROM THRU,10X,4HOHMS,8X,6HHENRYS,7X,6HFARADS,8X,4HRE
     3AL,6X,9HIMAGINARY,4X,10HMHOS/METER)
 26   FORMAT (/,10X,74HNOTE, SOME OF THE ABOVE SEGMENTS HAVE BEEN LOADED
     1 TWICE - IMPEDANCES ADDED)
 27   FORMAT (/,10X,46HIMPROPER LOAD TYPE CHOOSEN, REQUESTED TYPE IS ,I3
     1)
 28   FORMAT (/,10X,50HLOADING DATA CARD ERROR, NO SEGMENT HAS AN ITAG =
     1 ,I5)
 29   FORMAT (63H ERROR - LOADING MAY NOT BE ADDED TO SEGMENTS IN N.G.F.
     1 SECTION)
      END
!----------------------------------------------------------------------------

      SUBROUTINE LTSOLV (A,NROW,IX,B,NEQ,NRH,IFL1,IFL2)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     LTSOLV SOLVES THE MATRIX EQ. Y(R)*LU(T)=B(R) WHERE (R) DENOTES ROW
!     VECTOR AND LU(T) DENOTES THE LU DECOMPOSITION OF THE TRANSPOSE OF
!     THE ORIGINAL COEFFICIENT MATRIX.  THE LU(T) DECOMPOSITION IS
!     STORED ON TAPE 5 IN BLOCKS IN ASCENDING ORDER AND ON FILE 3 IN
!     BLOCKS OF DESCENDING ORDER.
!
      COMPLEX*16 A,B,Y,SUM
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      COMMON /SCRATM/ Y(2*MAXSEG)
      DIMENSION A(NROW,NROW), B(NEQ,NRH), IX(NEQ)
!
!     FORWARD SUBSTITUTION
!
      I2=2*NPSYM*NROW
      DO 4 IXBLK1=1,NBLSYM
      CALL BLCKIN (A,IFL1,1,I2,1,121)
      K2=NPSYM
      IF (IXBLK1.EQ.NBLSYM) K2=NLSYM
      JST=(IXBLK1-1)*NPSYM
      DO 4 IC=1,NRH
      J=JST
      DO 3 K=1,K2
      JM1=J
      J=J+1
      SUM=(0.,0.)
      IF (JM1.LT.1) GO TO 2
      DO 1 I=1,JM1
1     SUM=SUM+A(I,K)*B(I,IC)
2     B(J,IC)=(B(J,IC)-SUM)/A(J,K)
3     CONTINUE
4     CONTINUE
!
!     BACKWARD SUBSTITUTION
!
      JST=NROW+1
      DO 8 IXBLK1=1,NBLSYM
      CALL BLCKIN (A,IFL2,1,I2,1,122)
      K2=NPSYM
      IF (IXBLK1.EQ.1) K2=NLSYM
      DO 7 IC=1,NRH
      KP=K2+1
      J=JST
      DO 6 K=1,K2
      KP=KP-1
      JP1=J
      J=J-1
      SUM=(0.,0.)
      IF (NROW.LT.JP1) GO TO 6
      DO 5 I=JP1,NROW
5     SUM=SUM+A(I,KP)*B(I,IC)
      B(J,IC)=B(J,IC)-SUM
6     CONTINUE
7     CONTINUE
8     JST=JST-K2
!
!     UNSCRAMBLE SOLUTION
!
      DO 10 IC=1,NRH
      DO 9 I=1,NROW
      IXI=IX(I)
9     Y(IXI)=B(I,IC)
      DO 10 I=1,NROW
10    B(I,IC)=Y(I)
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE LUNSCR (A,NROW,NOP,IX,IP,IU2,IU3,IU4)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     S/R WHICH UNSCRAMBLES, SCRAMBLED FACTORED MATRIX
!
      COMPLEX*16 A,TEMP
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      DIMENSION A(NROW,1), IP(NROW), IX(NROW)
      I1=1
      I2=2*NPSYM*NROW
      NM1=NROW-1
      REWIND IU2
      REWIND IU3
      REWIND IU4
      DO 9 KK=1,NOP
      KA=(KK-1)*NROW
      DO 4 IXBLK1=1,NBLSYM
      CALL BLCKIN (A,IU2,I1,I2,1,121)
      K1=(IXBLK1-1)*NPSYM+2
      IF (NM1.LT.K1) GO TO 3
      J2=0
      DO 2 K=K1,NM1
      IF (J2.LT.NPSYM) J2=J2+1
      IPK=IP(K+KA)
      DO 1 J=1,J2
      TEMP=A(K,J)
      A(K,J)=A(IPK,J)
      A(IPK,J)=TEMP
1     CONTINUE
2     CONTINUE
3     CONTINUE
      CALL BLCKOT (A,IU3,I1,I2,1,122)
4     CONTINUE
      DO 5 IXBLK1=1,NBLSYM
      BACKSPACE IU3
      IF (IXBLK1.NE.1) BACKSPACE IU3
      CALL BLCKIN (A,IU3,I1,I2,1,123)
      CALL BLCKOT (A,IU4,I1,I2,1,124)
5     CONTINUE
      DO 6 I=1,NROW
      IX(I+KA)=I
6     CONTINUE
      DO 7 I=1,NROW
      IPI=IP(I+KA)
      IXT=IX(I+KA)
      IX(I+KA)=IX(IPI+KA)
      IX(IPI+KA)=IXT
7     CONTINUE
      IF (NOP.EQ.1) GO TO 9
      NB1=NBLSYM-1
!     SKIP NB1 LOGICAL RECORDS FORWARD
      DO 8 IXBLK1=1,NB1
      CALL BLCKIN (A,IU3,I1,I2,1,125)
8     CONTINUE
9     CONTINUE
      REWIND IU2
      REWIND IU3
      REWIND IU4
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE MOVE (ROX,ROY,ROZ,XS,YS,ZS,ITS,NRPT,ITGI)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     SUBROUTINE MOVE MOVES THE STRUCTURE WITH RESPECT TO ITS
!     COORDINATE SYSTEM OR REPRODUCES STRUCTURE IN NEW POSITIONS.
!     STRUCTURE IS ROTATED ABOUT X,Y,Z AXES BY ROX,ROY,ROZ
!     RESPECTIVELY, THEN SHIFTED BY XS,YS,ZS
!
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1), X2(1), Y
     12(1), Z2(1)
      EQUIVALENCE (X2(1),SI(1)), (Y2(1),ALP(1)), (Z2(1),BET(1))
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG)
      IF (ABS(ROX)+ABS(ROY).GT.1.D-10) IPSYM=IPSYM*3
      SPS=SIN(ROX)
      CPS=COS(ROX)
      STH=SIN(ROY)
      CTH=COS(ROY)
      SPH=SIN(ROZ)
      CPH=COS(ROZ)
      XX=CPH*CTH
      XY=CPH*STH*SPS-SPH*CPS
      XZ=CPH*STH*CPS+SPH*SPS
      YX=SPH*CTH
      YY=SPH*STH*SPS+CPH*CPS
      YZ=SPH*STH*CPS-CPH*SPS
      ZX=-STH
      ZY=CTH*SPS
      ZZ=CTH*CPS
      NRP=NRPT
      IF (NRPT.EQ.0) NRP=1
      IX=1
      IF (N.LT.N2) GO TO 3
      I1=ISEGNO(ITS,1)
      IF (I1.LT.N2) I1=N2
      IX=I1
      K=N
      IF (NRPT.EQ.0) K=I1-1
      DO 2 IR=1,NRP
      DO 1 I=I1,N
      K=K+1
      XI=X(I)
      YI=Y(I)
      ZI=Z(I)
      X(K)=XI*XX+YI*XY+ZI*XZ+XS
      Y(K)=XI*YX+YI*YY+ZI*YZ+YS
      Z(K)=XI*ZX+YI*ZY+ZI*ZZ+ZS
      XI=X2(I)
      YI=Y2(I)
      ZI=Z2(I)
      X2(K)=XI*XX+YI*XY+ZI*XZ+XS
      Y2(K)=XI*YX+YI*YY+ZI*YZ+YS
      Z2(K)=XI*ZX+YI*ZY+ZI*ZZ+ZS
      BI(K)=BI(I)
      ITAG(K)=ITAG(I)
      IF(ITAG(I).NE.0)ITAG(K)=ITAG(I)+ITGI
1     CONTINUE
      I1=N+1
      N=K
2     CONTINUE
3     IF (M.LT.M2) GO TO 6
      I1=M2
      K=M
      LDI=LD+1
      IF (NRPT.EQ.0) K=M1
      DO 5 II=1,NRP
      DO 4 I=I1,M
      K=K+1
      IR=LDI-I
      KR=LDI-K
      XI=X(IR)
      YI=Y(IR)
      ZI=Z(IR)
      X(KR)=XI*XX+YI*XY+ZI*XZ+XS
      Y(KR)=XI*YX+YI*YY+ZI*YZ+YS
      Z(KR)=XI*ZX+YI*ZY+ZI*ZZ+ZS
      XI=T1X(IR)
      YI=T1Y(IR)
      ZI=T1Z(IR)
      T1X(KR)=XI*XX+YI*XY+ZI*XZ
      T1Y(KR)=XI*YX+YI*YY+ZI*YZ
      T1Z(KR)=XI*ZX+YI*ZY+ZI*ZZ
      XI=T2X(IR)
      YI=T2Y(IR)
      ZI=T2Z(IR)
      T2X(KR)=XI*XX+YI*XY+ZI*XZ
      T2Y(KR)=XI*YX+YI*YY+ZI*YZ
      T2Z(KR)=XI*ZX+YI*ZY+ZI*ZZ
      SALP(KR)=SALP(IR)
4     BI(KR)=BI(IR)
      I1=M+1
5     M=K
6     IF ((NRPT.EQ.0).AND.(IX.EQ.1)) RETURN
      NP=N
      MP=M
      IPSYM=0
      RETURN
      END
         
!----------------------------------------------------------------------------

      SUBROUTINE NEFLD (XOB,YOB,ZOB,EX,EY,EZ)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     NEFLD COMPUTES THE NEAR FIELD AT SPECIFIED POINTS IN SPACE AFTER
!     THE STRUCTURE CURRENTS HAVE BEEN COMPUTED.
!
      COMPLEX*16 EX,EY,EZ,CUR,ACX,BCX,CCX,EXK,EYK,EZK,EXS,EYS,EZS,EXC
     1,EYC,EZC,ZRATI,ZRATI2,T1,FRATI
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
      COMMON /CRNT/ AIR(MAXSEG),AII(MAXSEG),BIR(MAXSEG),BII(MAXSEG),
     &CIR(MAXSEG),CII(MAXSEG),CUR(3*MAXSEG)
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      DIMENSION CAB(1), SAB(1), T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1),
     1T2Z(1)
      EQUIVALENCE (CAB,ALP), (SAB,BET)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG)
      EQUIVALENCE (T1XJ,CABJ), (T1YJ,SABJ), (T1ZJ,SALPJ), (T2XJ,B), (T2Y
     1J,IND1), (T2ZJ,IND2)

      EX=(0.,0.)
      EY=(0.,0.)
      EZ=(0.,0.)
      AX=0.
      IF (N.EQ.0) GO TO 20
      DO 1 I=1,N
      XJ=XOB-X(I)
      YJ=YOB-Y(I)
      ZJ=ZOB-Z(I)
      ZP=CAB(I)*XJ+SAB(I)*YJ+SALP(I)*ZJ
      IF (ABS(ZP).GT.0.5001*SI(I)) GO TO 1
      ZP=XJ*XJ+YJ*YJ+ZJ*ZJ-ZP*ZP
      XJ=BI(I)
      IF (ZP.GT.0.9*XJ*XJ) GO TO 1
      AX=XJ
      GO TO 2
1     CONTINUE
2     DO 19 I=1,N
      S=SI(I)
      B=BI(I)
      XJ=X(I)
      YJ=Y(I)
      ZJ=Z(I)
      CABJ=CAB(I)
      SABJ=SAB(I)
      SALPJ=SALP(I)
      IF (IEXK.EQ.0) GO TO 18

      IPR=ICON1(I)
      IF(IPR.GT.10000)GO TO 9      !<---NEW, av016
      IF (IPR) 3,8,4

3     IPR=-IPR
      IF (-ICON1(IPR).NE.I) GO TO 9
      GO TO 6
4     IF (IPR.NE.I) GO TO 5
      IF (CABJ*CABJ+SABJ*SABJ.GT.1.D-8) GO TO 9
      GO TO 7
5     IF (ICON2(IPR).NE.I) GO TO 9
6     XI=ABS(CABJ*CAB(IPR)+SABJ*SAB(IPR)+SALPJ*SALP(IPR))
      IF (XI.LT.0.999999D+0) GO TO 9
      IF (ABS(BI(IPR)/B-1.).GT.1.D-6) GO TO 9
7     IND1=0
      GO TO 10
8     IND1=1
      GO TO 10
9     IND1=2

10    IPR=ICON2(I)
      IF(IPR.GT.10000)GO TO 17    !<---NEW, av016
      IF (IPR) 11,16,12

11    IPR=-IPR
      IF (-ICON2(IPR).NE.I) GO TO 17
      GO TO 14
12    IF (IPR.NE.I) GO TO 13
      IF (CABJ*CABJ+SABJ*SABJ.GT.1.D-8) GO TO 17
      GO TO 15
13    IF (ICON1(IPR).NE.I) GO TO 17
14    XI=ABS(CABJ*CAB(IPR)+SABJ*SAB(IPR)+SALPJ*SALP(IPR))
      IF (XI.LT.0.999999D+0) GO TO 17
      IF (ABS(BI(IPR)/B-1.).GT.1.D-6) GO TO 17
15    IND2=0
      GO TO 18
16    IND2=1
      GO TO 18
17    IND2=2
18    CONTINUE
      CALL EFLD (XOB,YOB,ZOB,AX,1)
      ACX=DCMPLX(AIR(I),AII(I))
      BCX=DCMPLX(BIR(I),BII(I))
      CCX=DCMPLX(CIR(I),CII(I))
      EX=EX+EXK*ACX+EXS*BCX+EXC*CCX
      EY=EY+EYK*ACX+EYS*BCX+EYC*CCX
19    EZ=EZ+EZK*ACX+EZS*BCX+EZC*CCX
      IF (M.EQ.0) RETURN
20    JC=N
      JL=LD+1
      DO 21 I=1,M
      JL=JL-1
      S=BI(JL)
      XJ=X(JL)
      YJ=Y(JL)
      ZJ=Z(JL)
      T1XJ=T1X(JL)
      T1YJ=T1Y(JL)
      T1ZJ=T1Z(JL)
      T2XJ=T2X(JL)
      T2YJ=T2Y(JL)
      T2ZJ=T2Z(JL)
      JC=JC+3
      ACX=T1XJ*CUR(JC-2)+T1YJ*CUR(JC-1)+T1ZJ*CUR(JC)
      BCX=T2XJ*CUR(JC-2)+T2YJ*CUR(JC-1)+T2ZJ*CUR(JC)
      DO 21 IP=1,KSYMP
      IPGND=IP
      CALL UNERE (XOB,YOB,ZOB)
      EX=EX+ACX*EXK+BCX*EXS
      EY=EY+ACX*EYK+BCX*EYS
21    EZ=EZ+ACX*EZK+BCX*EZS
      RETURN
      END

!----------------------------------------------------------------------------

      SUBROUTINE NETWK (CM,CMB,CMC,CMD,IP,EINC)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     SUBROUTINE NETWK SOLVES FOR STRUCTURE CURRENTS FOR A GIVEN
!     EXCITATION INCLUDING THE EFFECT OF NON-RADIATING NETWORKS IF
!     PRESENT.
!
      COMPLEX*16 CMN,RHNT,YMIT,RHS,ZPED,EINC,VSANT,VLT,CUR,VSRC,RHNX
     1,VQD,VQDS,CUX,CM,CMB,CMC,CMD

      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM

      COMMON /CRNT/ AIR(MAXSEG),AII(MAXSEG),BIR(MAXSEG),BII(MAXSEG),
     &CIR(MAXSEG),CII(MAXSEG),CUR(3*MAXSEG)

      COMMON /VSORC/ VQD(nsmax),VSANT(nsmax),VQDS(nsmax),IVQD(nsmax),
     &ISANT(nsmax),IQDS(nsmax),NVQD,NSANT,NQDS			! av07

      COMMON/NETCX/ZPED,PIN,PNLS,X11R(netmx),X11I(netmx),X12R(netmx),
     &X12I(netmx),X22R(netmx),X22I(netmx),NTYP(netmx),ISEG1(netmx),
     &ISEG2(netmx),NEQ,NPEQ,NEQ2,NONET,NTSOL,NPRINT,MASYM	! av06

      DIMENSION EINC(1), IP(1),CM(1),CMB(1),CMC(1),CMD(1)

      DIMENSION CMN(netmx,netmx), RHNT(netmx), IPNT(netmx), 
     &NTEQA(netmx), NTSCA(netmx), RHS(3*MAXSEG), VSRC(netmx), 
     &RHNX(netmx)								! av017

!hwh  DATA NDIMN,NDIMNP/netmx,netmx+1/,TP/6.283185308D+0/	! av06
      DATA NDIMN,NDIMNP/netmx,netmxp1/,TP/6.283185308D+0/	! av06 hwh

      NEQZ2=NEQ2
      IF(NEQZ2.EQ.0)NEQZ2=1
      PIN=0.
      PNLS=0.
      NEQT=NEQ+NEQ2
      IF (NTSOL.NE.0) GO TO 42
      NOP=NEQ/NPEQ
      IF (MASYM.EQ.0) GO TO 14
!
!     COMPUTE RELATIVE MATRIX ASYMMETRY
!
      IROW1=0
      IF (NONET.EQ.0) GO TO 5
      DO 4 I=1,NONET
      NSEG1=ISEG1(I)
      DO 3 ISC1=1,2
      IF (IROW1.EQ.0) GO TO 2
      DO 1 J=1,IROW1
      IF (NSEG1.EQ.IPNT(J)) GO TO 3
1     CONTINUE
2     IROW1=IROW1+1
      IPNT(IROW1)=NSEG1
3     NSEG1=ISEG2(I)
4     CONTINUE
5     IF (NSANT.EQ.0) GO TO 9
      DO 8 I=1,NSANT
      NSEG1=ISANT(I)
      IF (IROW1.EQ.0) GO TO 7
      DO 6 J=1,IROW1
      IF (NSEG1.EQ.IPNT(J)) GO TO 8
6     CONTINUE
7     IROW1=IROW1+1
      IPNT(IROW1)=NSEG1
8     CONTINUE

9      IF (IROW1.LT.NDIMNP) GO TO 10
      WRITE(3,59)
      STOP
10    IF (IROW1.LT.2) GO TO 14
      DO 12 I=1,IROW1
      ISC1=IPNT(I)
      ASM=SI(ISC1)
      DO 11 J=1,NEQT
11    RHS(J)=(0.,0.)
      RHS(ISC1)=(1.,0.)
      CALL SOLGF (CM,CMB,CMC,CMD,RHS,IP,NP,N1,N,MP,M1,M,NEQ,NEQ2,NEQZ2)
      CALL CABC (RHS)
      DO 12 J=1,IROW1
      ISC1=IPNT(J)
12    CMN(J,I)=RHS(ISC1)/ASM
      ASM=0.
      ASA=0.
      DO 13 I=2,IROW1
      ISC1=I-1
      DO 13 J=1,ISC1
      CUX=CMN(I,J)
      PWR=ABS((CUX-CMN(J,I))/CUX)
      ASA=ASA+PWR*PWR
      IF (PWR.LT.ASM) GO TO 13
      ASM=PWR
      NTEQ=IPNT(I)
      NTSC=IPNT(J)
13    CONTINUE
      ASA=SQRT(ASA*2./DFLOAT(IROW1*(IROW1-1)))
      WRITE(3,58)  ASM,NTEQ,NTSC,ASA
14    IF (NONET.EQ.0) GO TO 48
!
!     SOLUTION OF NETWORK EQUATIONS
!
      DO 15 I=1,NDIMN
      RHNX(I)=(0.,0.)
      DO 15 J=1,NDIMN
15    CMN(I,J)=(0.,0.)
      NTEQ=0
      NTSC=0
!
!     SORT NETWORK AND SOURCE DATA AND ASSIGN EQUATION NUMBERS TO
!     SEGMENTS.
!
      DO 38 J=1,NONET
      NSEG1=ISEG1(J)
      NSEG2=ISEG2(J)
      IF (NTYP(J).GT.1) GO TO 16
      Y11R=X11R(J)
      Y11I=X11I(J)
      Y12R=X12R(J)
      Y12I=X12I(J)
      Y22R=X22R(J)
      Y22I=X22I(J)
      GO TO 17
16    Y22R=TP*X11I(J)/WLAM
      Y12R=0.
      Y12I=1./(X11R(J)*SIN(Y22R))
      Y11R=X12R(J)
      Y11I=-Y12I*COS(Y22R)
      Y22R=X22R(J)
      Y22I=Y11I+X22I(J)
      Y11I=Y11I+X12I(J)
      IF (NTYP(J).EQ.2) GO TO 17
      Y12R=-Y12R
      Y12I=-Y12I
17    IF (NSANT.EQ.0) GO TO 19
      DO 18 I=1,NSANT
      IF (NSEG1.NE.ISANT(I)) GO TO 18
      ISC1=I
      GO TO 22
18    CONTINUE
19    ISC1=0
      IF (NTEQ.EQ.0) GO TO 21
      DO 20 I=1,NTEQ
      IF (NSEG1.NE.NTEQA(I)) GO TO 20
      IROW1=I
      GO TO 25
20    CONTINUE
21    NTEQ=NTEQ+1
      IROW1=NTEQ
      NTEQA(NTEQ)=NSEG1
      GO TO 25
22    IF (NTSC.EQ.0) GO TO 24
      DO 23 I=1,NTSC
      IF (NSEG1.NE.NTSCA(I)) GO TO 23
      IROW1=NDIMNP-I
      GO TO 25
23    CONTINUE
24    NTSC=NTSC+1
      IROW1=NDIMNP-NTSC
      NTSCA(NTSC)=NSEG1
      VSRC(NTSC)=VSANT(ISC1)
25    IF (NSANT.EQ.0) GO TO 27
      DO 26 I=1,NSANT
      IF (NSEG2.NE.ISANT(I)) GO TO 26
      ISC2=I
      GO TO 30
26    CONTINUE
27    ISC2=0
      IF (NTEQ.EQ.0) GO TO 29
      DO 28 I=1,NTEQ
      IF (NSEG2.NE.NTEQA(I)) GO TO 28
      IROW2=I
      GO TO 33
28    CONTINUE
29    NTEQ=NTEQ+1
      IROW2=NTEQ
      NTEQA(NTEQ)=NSEG2
      GO TO 33
30    IF (NTSC.EQ.0) GO TO 32
      DO 31 I=1,NTSC
      IF (NSEG2.NE.NTSCA(I)) GO TO 31
      IROW2=NDIMNP-I
      GO TO 33
31    CONTINUE
32    NTSC=NTSC+1
      IROW2=NDIMNP-NTSC
      NTSCA(NTSC)=NSEG2
      VSRC(NTSC)=VSANT(ISC2)
33    IF (NTSC+NTEQ.LT.NDIMNP) GO TO 34
      WRITE(3,59)
      STOP
!
!     FILL NETWORK EQUATION MATRIX AND RIGHT HAND SIDE VECTOR WITH
!     NETWORK SHORT-CIRCUIT ADMITTANCE MATRIX COEFFICIENTS.
!
34    IF (ISC1.NE.0) GO TO 35
      CMN(IROW1,IROW1)=CMN(IROW1,IROW1)-DCMPLX(Y11R,Y11I)*SI(NSEG1)
      CMN(IROW1,IROW2)=CMN(IROW1,IROW2)-DCMPLX(Y12R,Y12I)*SI(NSEG1)
      GO TO 36
35    RHNX(IROW1)=RHNX(IROW1)+DCMPLX(Y11R,Y11I)*VSANT(ISC1)/WLAM
      RHNX(IROW2)=RHNX(IROW2)+DCMPLX(Y12R,Y12I)*VSANT(ISC1)/WLAM
36    IF (ISC2.NE.0) GO TO 37
      CMN(IROW2,IROW2)=CMN(IROW2,IROW2)-DCMPLX(Y22R,Y22I)*SI(NSEG2)
      CMN(IROW2,IROW1)=CMN(IROW2,IROW1)-DCMPLX(Y12R,Y12I)*SI(NSEG2)
      GO TO 38
37    RHNX(IROW1)=RHNX(IROW1)+DCMPLX(Y12R,Y12I)*VSANT(ISC2)/WLAM
      RHNX(IROW2)=RHNX(IROW2)+DCMPLX(Y22R,Y22I)*VSANT(ISC2)/WLAM
38    CONTINUE
!
!     ADD INTERACTION MATRIX ADMITTANCE ELEMENTS TO NETWORK EQUATION
!     MATRIX
!
      DO 41 I=1,NTEQ
      DO 39 J=1,NEQT
39    RHS(J)=(0.,0.)
      IROW1=NTEQA(I)
      RHS(IROW1)=(1.,0.)
      CALL SOLGF (CM,CMB,CMC,CMD,RHS,IP,NP,N1,N,MP,M1,M,NEQ,NEQ2,NEQZ2)
      CALL CABC (RHS)
      DO 40 J=1,NTEQ
      IROW1=NTEQA(J)
40    CMN(I,J)=CMN(I,J)+RHS(IROW1)
41    CONTINUE
!
!     FACTOR NETWORK EQUATION MATRIX
!
      CALL FACTR (NTEQ,CMN,IPNT,NDIMN)
!
!     ADD TO NETWORK EQUATION RIGHT HAND SIDE THE TERMS DUE TO ELEMENT
!     INTERACTIONS
!
42    IF (NONET.EQ.0) GO TO 48
      DO 43 I=1,NEQT
43    RHS(I)=EINC(I)
      CALL SOLGF (CM,CMB,CMC,CMD,RHS,IP,NP,N1,N,MP,M1,M,NEQ,NEQ2,NEQZ2)
      CALL CABC (RHS)
      DO 44 I=1,NTEQ
      IROW1=NTEQA(I)
44    RHNT(I)=RHNX(I)+RHS(IROW1)
!
!     SOLVE NETWORK EQUATIONS
!
      CALL SOLVE (NTEQ,CMN,IPNT,RHNT,NDIMN)
!
!     ADD FIELDS DUE TO NETWORK VOLTAGES TO ELECTRIC FIELDS APPLIED TO
!     STRUCTURE AND SOLVE FOR INDUCED CURRENT
!
      DO 45 I=1,NTEQ
      IROW1=NTEQA(I)
45    EINC(IROW1)=EINC(IROW1)-RHNT(I)
      CALL SOLGF (CM,CMB,CMC,CMD,EINC,IP,NP,N1,N,MP,M1,M,NEQ,NEQ2,NEQZ2)
      CALL CABC (EINC)
      IF (NPRINT.EQ.0) WRITE(3,61)
      IF (NPRINT.EQ.0) WRITE(3,60)
      DO 46 I=1,NTEQ
      IROW1=NTEQA(I)
      VLT=RHNT(I)*SI(IROW1)*WLAM
      CUX=EINC(IROW1)*WLAM
      YMIT=CUX/VLT
      ZPED=VLT/CUX
      IROW2=ITAG(IROW1)
      PWR=.5*DREAL(VLT*DCONJG(CUX))
      PNLS=PNLS-PWR
46    IF (NPRINT.EQ.0) WRITE(3,62)  IROW2,IROW1,VLT,CUX,ZPED,YMIT,PWR
      IF (NTSC.EQ.0) GO TO 49
      DO 47 I=1,NTSC
      IROW1=NTSCA(I)
      VLT=VSRC(I)
      CUX=EINC(IROW1)*WLAM
      YMIT=CUX/VLT
      ZPED=VLT/CUX
      IROW2=ITAG(IROW1)
      PWR=.5*DREAL(VLT*DCONJG(CUX))
      PNLS=PNLS-PWR
47    IF (NPRINT.EQ.0) WRITE(3,62)  IROW2,IROW1,VLT,CUX,ZPED,YMIT,PWR
      GO TO 49
!
!     SOLVE FOR CURRENTS WHEN NO NETWORKS ARE PRESENT
!
48    CALL SOLGF (CM,CMB,CMC,CMD,EINC,IP,NP,N1,N,MP,M1,M,NEQ,NEQ2,NEQZ2)
      CALL CABC (EINC)
      NTSC=0
49    IF (NSANT+NVQD.EQ.0) RETURN
      WRITE(3,63)
      WRITE(3,60)
      IF (NSANT.EQ.0) GO TO 56
      DO 55 I=1,NSANT
      ISC1=ISANT(I)
      VLT=VSANT(I)
      IF (NTSC.EQ.0) GO TO 51
      DO 50 J=1,NTSC
      IF (NTSCA(J).EQ.ISC1) GO TO 52
50    CONTINUE
51    CUX=EINC(ISC1)*WLAM
      IROW1=0
      GO TO 54
52    IROW1=NDIMNP-J
      CUX=RHNX(IROW1)
      DO 53 J=1,NTEQ
53    CUX=CUX-CMN(J,IROW1)*RHNT(J)
      CUX=(EINC(ISC1)+CUX)*WLAM
54    YMIT=CUX/VLT
      ZPED=VLT/CUX
      PWR=.5*DREAL(VLT*DCONJG(CUX))
      PIN=PIN+PWR
      IF (IROW1.NE.0) PNLS=PNLS+PWR
      IROW2=ITAG(ISC1)
55    WRITE(3,62)  IROW2,ISC1,VLT,CUX,ZPED,YMIT,PWR
56    IF (NVQD.EQ.0) RETURN
      DO 57 I=1,NVQD
      ISC1=IVQD(I)
      VLT=VQD(I)
      CUX=DCMPLX(AIR(ISC1),AII(ISC1))
      YMIT=DCMPLX(BIR(ISC1),BII(ISC1))
      ZPED=DCMPLX(CIR(ISC1),CII(ISC1))
      PWR=SI(ISC1)*TP*.5
      CUX=(CUX-YMIT*SIN(PWR)+ZPED*COS(PWR))*WLAM
      YMIT=CUX/VLT
      ZPED=VLT/CUX
      PWR=.5*DREAL(VLT*DCONJG(CUX))
      PIN=PIN+PWR
      IROW2=ITAG(ISC1)
57    WRITE(3,64)  IROW2,ISC1,VLT,CUX,ZPED,YMIT,PWR
      RETURN
!
58    FORMAT (///,3X,47HMAXIMUM RELATIVE ASYMMETRY OF THE DRIVING POINT,
     121H ADMITTANCE MATRIX IS,1P,E10.3,13H FOR SEGMENTS,I5,4H AND,I5,/,
     23X,25HRMS RELATIVE ASYMMETRY IS,E10.3)
59    FORMAT (1X,44HERROR - - NETWORK ARRAY DIMENSIONS TOO SMALL)
60    FORMAT (/,3X,3HTAG,3X,4HSEG.,4X,15HVOLTAGE (VOLTS),9X,14HCURRENT (
     1AMPS),9X,16HIMPEDANCE (OHMS),8X,17HADMITTANCE (MHOS),6X,5HPOWER,/,
     23X,3HNO.,3X,3HNO.,4X,4HREAL,8X,5HIMAG.,3(7X,4HREAL,8X,5HIMAG.),5X,
     37H(WATTS))
61    FORMAT (///,27X,66H- - - STRUCTURE EXCITATION DATA AT NETWORK CONN
     1ECTION POINTS - - -)
62    FORMAT (2(1X,I5),1P,9E12.5)
63    FORMAT (///,42X,36H- - - ANTENNA INPUT PARAMETERS - - -)
64    FORMAT (1X,I5,2H *,I4,1P,9E12.5)
      END
!----------------------------------------------------------------------------

      SUBROUTINE NFPAT
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     COMPUTE NEAR E OR H FIELDS OVER A RANGE OF POINTS
      COMPLEX*16 EX,EY,EZ
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON/FPAT/THETS,PHIS,DTH,DPH,RFLD,GNOR,CLT,CHT,EPSR2,SIG2,
     &XPR6,PINR,PNLR,PLOSS,XNR,YNR,ZNR,DXNR,DYNR,DZNR,NTH,NPH,IPD,IAVP,
     &INOR,IAX,IXTYP,NEAR,NFEH,NRX,NRY,NRZ
!***
      COMMON /PLOT/ IPLP1,IPLP2,IPLP3,IPLP4
!***
      DATA TA/1.745329252D-02/
      IF (NFEH.EQ.1) GO TO 1
      WRITE(3,10)
      GO TO 2
1     WRITE(3,12)
2     ZNRT=ZNR-DZNR
      DO 9 I=1,NRZ
      ZNRT=ZNRT+DZNR
      IF (NEAR.EQ.0) GO TO 3
      CTH=COS(TA*ZNRT)
      STH=SIN(TA*ZNRT)
3     YNRT=YNR-DYNR
      DO 9 J=1,NRY
      YNRT=YNRT+DYNR
      IF (NEAR.EQ.0) GO TO 4
      CPH=COS(TA*YNRT)
      SPH=SIN(TA*YNRT)
4     XNRT=XNR-DXNR
      DO 9 KK=1,NRX
      XNRT=XNRT+DXNR
      IF (NEAR.EQ.0) GO TO 5
      XOB=XNRT*STH*CPH
      YOB=XNRT*STH*SPH
      ZOB=XNRT*CTH
      GO TO 6
5     XOB=XNRT
      YOB=YNRT
      ZOB=ZNRT
6     TMP1=XOB/WLAM
      TMP2=YOB/WLAM
      TMP3=ZOB/WLAM
      IF (NFEH.EQ.1) GO TO 7
      CALL NEFLD (TMP1,TMP2,TMP3,EX,EY,EZ)
      GO TO 8
7     CALL NHFLD (TMP1,TMP2,TMP3,EX,EY,EZ)
8     TMP1=ABS(EX)
      TMP2=CANG(EX)
      TMP3=ABS(EY)
      TMP4=CANG(EY)
      TMP5=ABS(EZ)
      TMP6=CANG(EZ)
      WRITE(3,11)  XOB,YOB,ZOB,TMP1,TMP2,TMP3,TMP4,TMP5,TMP6
!***
      IF(IPLP1 .NE. 2) GO TO 9
      GO TO (14,15,16),IPLP4
14    XXX=XOB
      GO TO 17
15    XXX=YOB
      GO TO 17
16    XXX=ZOB
17    CONTINUE
      IF(IPLP2 .NE. 2) GO TO 13
      IF(IPLP3 .EQ. 1) WRITE(8,*) XXX,TMP1,TMP2
      IF(IPLP3 .EQ. 2) WRITE(8,*) XXX,TMP3,TMP4
      IF(IPLP3 .EQ. 3) WRITE(8,*) XXX,TMP5,TMP6
      IF(IPLP3 .EQ. 4) WRITE(8,*) XXX,TMP1,TMP2,TMP3,TMP4,TMP5,TMP6
      GO TO 9
13    IF(IPLP2 .NE. 1) GO TO 9
      IF(IPLP3 .EQ. 1) WRITE(8,*) XXX,EX
      IF(IPLP3 .EQ. 2) WRITE(8,*) XXX,EY
      IF(IPLP3 .EQ. 3) WRITE(8,*) XXX,EZ
      IF(IPLP3 .EQ. 4) WRITE(8,*) XXX,EX,EY,EZ
!***
9     CONTINUE
      RETURN
!
10    FORMAT (///,35X,32H- - - NEAR ELECTRIC FIELDS - - -,//,12X,14H-  L
     1OCATION  -,21X,8H-  EX  -,15X,8H-  EY  -,15X,8H-  EZ  -,/,8X,1HX,1
     20X,1HY,10X,1HZ,10X,9HMAGNITUDE,3X,5HPHASE,6X,9HMAGNITUDE,3X,5HPHAS
     3E,6X,9HMAGNITUDE,3X,5HPHASE,/,6X,6HMETERS,5X,6HMETERS,5X,6HMETERS,
     48X,7HVOLTS/M,3X,7HDEGREES,6X,7HVOLTS/M,3X,7HDEGREES,6X,7HVOLTS/M,3
     5X,7HDEGREES)
11    FORMAT (2X,3(2X,F9.4),1X,3(3X,1P,E11.4,2X,0P,F7.2))
12    FORMAT (///,35X,32H- - - NEAR MAGNETIC FIELDS - - -,//,12X,14H-  L
     1OCATION  -,21X,8H-  HX  -,15X,8H-  HY  -,15X,8H-  HZ  -,/,8X,1HX,1
     20X,1HY,10X,1HZ,10X,9HMAGNITUDE,3X,5HPHASE,6X,9HMAGNITUDE,3X,5HPHAS
     3E,6X,9HMAGNITUDE,3X,5HPHASE,/,6X,6HMETERS,5X,6HMETERS,5X,6HMETERS,
     49X,6HAMPS/M,3X,7HDEGREES,7X,6HAMPS/M,3X,7HDEGREES,7X,6HAMPS/M,3X,7
     5HDEGREES)
      END
!----------------------------------------------------------------------------

      SUBROUTINE NHFLD (XOB,YOB,ZOB,HX,HY,HZ)
!
!     NHFLD COMPUTES THE NEAR FIELD AT SPECIFIED POINTS IN SPACE AFTER
!     THE STRUCTURE CURRENTS HAVE BEEN COMPUTED.
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
      COMPLEX*16 HX,HY,HZ,CUR,ACX,BCX,CCX,EXK,EYK,EZK,EXS,EYS,EZS,EXC,
     &EYC,EZC
!***************************************
      COMPLEX*16 ZRATI,ZRATI2,FRATI,T1,CON
      COMPLEX*16 EXPX,EXMX,EXPY,EXMY,EXPZ,EXMZ
      COMPLEX*16 EYPX,EYMX,EYPY,EYMY,EYPZ,EYMZ
      COMPLEX*16 EZPX,EZMX,EZPY,EZMY,EZPZ,EZMZ
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
!***************************************
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
      COMMON /CRNT/ AIR(MAXSEG),AII(MAXSEG),BIR(MAXSEG),BII(MAXSEG),
     &CIR(MAXSEG),CII(MAXSEG),CUR(3*MAXSEG)
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      DIMENSION CAB(1), SAB(1)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1), XS(1), Y
     1S(1), ZS(1)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG), (XS,X), (YS,Y), (ZS,Z)
      EQUIVALENCE (T1XJ,CABJ), (T1YJ,SABJ), (T1ZJ,SALPJ), (T2XJ,B), (T2Y
     1J,IND1), (T2ZJ,IND2)
      EQUIVALENCE (CAB,ALP), (SAB,BET)
!***************************************
      IF (IPERF.EQ.2) GO TO 6
!***************************************
      HX=(0.,0.)
      HY=(0.,0.)
      HZ=(0.,0.)
      AX=0.
      IF (N.EQ.0) GO TO 4
      DO 1 I=1,N
      XJ=XOB-X(I)
      YJ=YOB-Y(I)
      ZJ=ZOB-Z(I)
      ZP=CAB(I)*XJ+SAB(I)*YJ+SALP(I)*ZJ
      IF (ABS(ZP).GT.0.5001*SI(I)) GO TO 1
      ZP=XJ*XJ+YJ*YJ+ZJ*ZJ-ZP*ZP
      XJ=BI(I)
      IF (ZP.GT.0.9*XJ*XJ) GO TO 1
      AX=XJ
      GO TO 2
1     CONTINUE
2     DO 3 I=1,N
      S=SI(I)
      B=BI(I)
      XJ=X(I)
      YJ=Y(I)
      ZJ=Z(I)
      CABJ=CAB(I)
      SABJ=SAB(I)
      SALPJ=SALP(I)
      CALL HSFLD (XOB,YOB,ZOB,AX)
      ACX=DCMPLX(AIR(I),AII(I))
      BCX=DCMPLX(BIR(I),BII(I))
      CCX=DCMPLX(CIR(I),CII(I))
      HX=HX+EXK*ACX+EXS*BCX+EXC*CCX
      HY=HY+EYK*ACX+EYS*BCX+EYC*CCX
3     HZ=HZ+EZK*ACX+EZS*BCX+EZC*CCX
      IF (M.EQ.0) RETURN
4     JC=N
      JL=LD+1
      DO 5 I=1,M
      JL=JL-1
      S=BI(JL)
      XJ=X(JL)
      YJ=Y(JL)
      ZJ=Z(JL)
      T1XJ=T1X(JL)
      T1YJ=T1Y(JL)
      T1ZJ=T1Z(JL)
      T2XJ=T2X(JL)
      T2YJ=T2Y(JL)
      T2ZJ=T2Z(JL)
      CALL HINTG (XOB,YOB,ZOB)
      JC=JC+3
      ACX=T1XJ*CUR(JC-2)+T1YJ*CUR(JC-1)+T1ZJ*CUR(JC)
      BCX=T2XJ*CUR(JC-2)+T2YJ*CUR(JC-1)+T2ZJ*CUR(JC)
      HX=HX+ACX*EXK+BCX*EXS
      HY=HY+ACX*EYK+BCX*EYS
5     HZ=HZ+ACX*EZK+BCX*EZS
      RETURN
!
!     GET H BY FINITE DIFFERENCE OF E FOR SOMMERFELD GROUND
!     CON=j/(2*pi*eta)
!     DELT is the increment for getting central differences
!
6     DELT=1.E-3
      CON=(0.,4.2246E-4)
      CALL NEFLD (XOB+DELT,YOB,ZOB,EXPX,EYPX,EZPX)
      CALL NEFLD (XOB-DELT,YOB,ZOB,EXMX,EYMX,EZMX)
      CALL NEFLD (XOB,YOB+DELT,ZOB,EXPY,EYPY,EZPY)
      CALL NEFLD (XOB,YOB-DELT,ZOB,EXMY,EYMY,EZMY)
      CALL NEFLD (XOB,YOB,ZOB+DELT,EXPZ,EYPZ,EZPZ)
      CALL NEFLD (XOB,YOB,ZOB-DELT,EXMZ,EYMZ,EZMZ)
      HX=CON*(EZPY-EZMY-EYPZ+EYMZ)/(2.*DELT)
      HY=CON*(EXPZ-EXMZ-EZPX+EZMX)/(2.*DELT)
      HZ=CON*(EYPX-EYMX-EXPY+EXMY)/(2.*DELT)
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE PATCH (NX,NY,X1,Y1,Z1,X2,Y2,Z2,X3,Y3,Z3,X4,Y4,Z4)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     PATCH GENERATES AND MODIFIES PATCH GEOMETRY DATA
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG)
!     NEW PATCHES.  FOR NX=0, NY=1,2,3,4 PATCH IS (RESPECTIVELY)
!     ARBITRARY, RECTAGULAR, TRIANGULAR, OR QUADRILATERAL.
!     FOR NX AND NY .GT. 0 A RECTANGULAR SURFACE IS PRODUCED WITH
!     NX BY NY RECTANGULAR PATCHES.
      M=M+1
      MI=LD+1-M
      NTP=NY
      IF (NX.GT.0) NTP=2
      IF (NTP.GT.1) GO TO 2
      X(MI)=X1
      Y(MI)=Y1
      Z(MI)=Z1
      BI(MI)=Z2
      ZNV=COS(X2)
      XNV=ZNV*COS(Y2)
      YNV=ZNV*SIN(Y2)
      ZNV=SIN(X2)
      XA=SQRT(XNV*XNV+YNV*YNV)
      IF (XA.LT.1.D-6) GO TO 1
      T1X(MI)=-YNV/XA
      T1Y(MI)=XNV/XA
      T1Z(MI)=0.
      GO TO 6
1     T1X(MI)=1.
      T1Y(MI)=0.
      T1Z(MI)=0.
      GO TO 6
2     S1X=X2-X1
      S1Y=Y2-Y1
      S1Z=Z2-Z1
      S2X=X3-X2
      S2Y=Y3-Y2
      S2Z=Z3-Z2
      IF (NX.EQ.0) GO TO 3
      S1X=S1X/NX
      S1Y=S1Y/NX
      S1Z=S1Z/NX
      S2X=S2X/NY
      S2Y=S2Y/NY
      S2Z=S2Z/NY
3     XNV=S1Y*S2Z-S1Z*S2Y
      YNV=S1Z*S2X-S1X*S2Z
      ZNV=S1X*S2Y-S1Y*S2X
      XA=SQRT(XNV*XNV+YNV*YNV+ZNV*ZNV)
      XNV=XNV/XA
      YNV=YNV/XA
      ZNV=ZNV/XA
      XST=SQRT(S1X*S1X+S1Y*S1Y+S1Z*S1Z)
      T1X(MI)=S1X/XST
      T1Y(MI)=S1Y/XST
      T1Z(MI)=S1Z/XST
      IF (NTP.GT.2) GO TO 4
      X(MI)=X1+.5*(S1X+S2X)
      Y(MI)=Y1+.5*(S1Y+S2Y)
      Z(MI)=Z1+.5*(S1Z+S2Z)
      BI(MI)=XA
      GO TO 6
4     IF (NTP.EQ.4) GO TO 5
      X(MI)=(X1+X2+X3)/3.
      Y(MI)=(Y1+Y2+Y3)/3.
      Z(MI)=(Z1+Z2+Z3)/3.
      BI(MI)=.5*XA
      GO TO 6
5     S1X=X3-X1
      S1Y=Y3-Y1
      S1Z=Z3-Z1
      S2X=X4-X1
      S2Y=Y4-Y1
      S2Z=Z4-Z1
      XN2=S1Y*S2Z-S1Z*S2Y
      YN2=S1Z*S2X-S1X*S2Z
      ZN2=S1X*S2Y-S1Y*S2X
      XST=SQRT(XN2*XN2+YN2*YN2+ZN2*ZN2)
      SALPN=1./(3.*(XA+XST))
      X(MI)=(XA*(X1+X2+X3)+XST*(X1+X3+X4))*SALPN
      Y(MI)=(XA*(Y1+Y2+Y3)+XST*(Y1+Y3+Y4))*SALPN
      Z(MI)=(XA*(Z1+Z2+Z3)+XST*(Z1+Z3+Z4))*SALPN
      BI(MI)=.5*(XA+XST)
      S1X=(XNV*XN2+YNV*YN2+ZNV*ZN2)/XST
      IF (S1X.GT.0.9998) GO TO 6
      WRITE(3,14)
      STOP
6     T2X(MI)=YNV*T1Z(MI)-ZNV*T1Y(MI)
      T2Y(MI)=ZNV*T1X(MI)-XNV*T1Z(MI)
      T2Z(MI)=XNV*T1Y(MI)-YNV*T1X(MI)
      SALP(MI)=1.
      IF (NX.EQ.0) GO TO 8
      M=M+NX*NY-1
      XN2=X(MI)-S1X-S2X
      YN2=Y(MI)-S1Y-S2Y
      ZN2=Z(MI)-S1Z-S2Z
      XS=T1X(MI)
      YS=T1Y(MI)
      ZS=T1Z(MI)
      XT=T2X(MI)
      YT=T2Y(MI)
      ZT=T2Z(MI)
      MI=MI+1
      DO 7 IY=1,NY
      XN2=XN2+S2X
      YN2=YN2+S2Y
      ZN2=ZN2+S2Z
      DO 7 IX=1,NX
      XST=IX
      MI=MI-1
      X(MI)=XN2+XST*S1X
      Y(MI)=YN2+XST*S1Y
      Z(MI)=ZN2+XST*S1Z
      BI(MI)=XA
      SALP(MI)=1.
      T1X(MI)=XS
      T1Y(MI)=YS
      T1Z(MI)=ZS
      T2X(MI)=XT
      T2Y(MI)=YT
7     T2Z(MI)=ZT
8     IPSYM=0
      NP=N
      MP=M
      RETURN
!     DIVIDE PATCH FOR WIRE CONNECTION
      ENTRY SUBPH (NX,NY,X1,Y1,Z1,X2,Y2,Z2,X3,Y3,Z3,X4,Y4,Z4)
      IF (NY.GT.0) GO TO 10
      IF (NX.EQ.M) GO TO 10
      NXP=NX+1
      IX=LD-M
      DO 9 IY=NXP,M
      IX=IX+1
      NYP=IX-3
      X(NYP)=X(IX)
      Y(NYP)=Y(IX)
      Z(NYP)=Z(IX)
      BI(NYP)=BI(IX)
      SALP(NYP)=SALP(IX)
      T1X(NYP)=T1X(IX)
      T1Y(NYP)=T1Y(IX)
      T1Z(NYP)=T1Z(IX)
      T2X(NYP)=T2X(IX)
      T2Y(NYP)=T2Y(IX)
9     T2Z(NYP)=T2Z(IX)
10    MI=LD+1-NX
      XS=X(MI)
      YS=Y(MI)
      ZS=Z(MI)
      XA=BI(MI)*.25
      XST=SQRT(XA)*.5
      S1X=T1X(MI)
      S1Y=T1Y(MI)
      S1Z=T1Z(MI)
      S2X=T2X(MI)
      S2Y=T2Y(MI)
      S2Z=T2Z(MI)
      SALN=SALP(MI)
      XT=XST
      YT=XST
      IF (NY.GT.0) GO TO 11
      MIA=MI
      GO TO 12
11    M=M+1
      MP=MP+1
      MIA=LD+1-M
12    DO 13 IX=1,4
      X(MIA)=XS+XT*S1X+YT*S2X
      Y(MIA)=YS+XT*S1Y+YT*S2Y
      Z(MIA)=ZS+XT*S1Z+YT*S2Z
      BI(MIA)=XA
      T1X(MIA)=S1X
      T1Y(MIA)=S1Y
      T1Z(MIA)=S1Z
      T2X(MIA)=S2X
      T2Y(MIA)=S2Y
      T2Z(MIA)=S2Z
      SALP(MIA)=SALN
      IF (IX.EQ.2) YT=-YT
      IF (IX.EQ.1.OR.IX.EQ.3) XT=-XT
      MIA=MIA-1
13    CONTINUE
      M=M+3
      IF (NX.LE.MP) MP=MP+3
      IF (NY.GT.0) Z(MI)=10000.
      RETURN
!
14    FORMAT (62H ERROR -- CORNERS OF QUADRILATERAL PATCH DO NOT LIE IN 
     1A PLANE)
      END
!----------------------------------------------------------------------------

      SUBROUTINE PCINT (XI,YI,ZI,CABI,SABI,SALPI,E)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     INTEGRATE OVER PATCHES AT WIRE CONNECTION POINT
      COMPLEX*16 EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC,E,E1,E2,E3,E4,E5
     1,E6,E7,E8,E9
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      DIMENSION E(9)
      EQUIVALENCE (T1XJ,CABJ), (T1YJ,SABJ), (T1ZJ,SALPJ), (T2XJ,B), (T2Y
     1J,IND1), (T2ZJ,IND2)
      DATA TPI/6.283185308D+0/,NINT/10/
      D=SQRT(S)*.5
      DS=4.*D/DFLOAT(NINT)
      DA=DS*DS
      GCON=1./S
      FCON=1./(2.*TPI*D)
      XXJ=XJ
      XYJ=YJ
      XZJ=ZJ
      XS=S
      S=DA
      S1=D+DS*.5
      XSS=XJ+S1*(T1XJ+T2XJ)
      YSS=YJ+S1*(T1YJ+T2YJ)
      ZSS=ZJ+S1*(T1ZJ+T2ZJ)
      S1=S1+D
      S2X=S1
      E1=(0.,0.)
      E2=(0.,0.)
      E3=(0.,0.)
      E4=(0.,0.)
      E5=(0.,0.)
      E6=(0.,0.)
      E7=(0.,0.)
      E8=(0.,0.)
      E9=(0.,0.)
      DO 1 I1=1,NINT
      S1=S1-DS
      S2=S2X
      XSS=XSS-DS*T1XJ
      YSS=YSS-DS*T1YJ
      ZSS=ZSS-DS*T1ZJ
      XJ=XSS
      YJ=YSS
      ZJ=ZSS
      DO 1 I2=1,NINT
      S2=S2-DS
      XJ=XJ-DS*T2XJ
      YJ=YJ-DS*T2YJ
      ZJ=ZJ-DS*T2ZJ
      CALL UNERE (XI,YI,ZI)
      EXK=EXK*CABI+EYK*SABI+EZK*SALPI
      EXS=EXS*CABI+EYS*SABI+EZS*SALPI
      G1=(D+S1)*(D+S2)*GCON
      G2=(D-S1)*(D+S2)*GCON
      G3=(D-S1)*(D-S2)*GCON
      G4=(D+S1)*(D-S2)*GCON
      F2=(S1*S1+S2*S2)*TPI
      F1=S1/F2-(G1-G2-G3+G4)*FCON
      F2=S2/F2-(G1+G2-G3-G4)*FCON
      E1=E1+EXK*G1
      E2=E2+EXK*G2
      E3=E3+EXK*G3
      E4=E4+EXK*G4
      E5=E5+EXS*G1
      E6=E6+EXS*G2
      E7=E7+EXS*G3
      E8=E8+EXS*G4
1     E9=E9+EXK*F1+EXS*F2
      E(1)=E1
      E(2)=E2
      E(3)=E3
      E(4)=E4
      E(5)=E5
      E(6)=E6
      E(7)=E7
      E(8)=E8
      E(9)=E9
      XJ=XXJ
      YJ=XYJ
      ZJ=XZJ
      S=XS
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE PRNT(IN1,IN2,IN3,FL1,FL2,FL3,FL4,FL5,FL6,CTYPE)
!
!     Purpose:
!     PRNT prints the input data for impedance loading, inserting blanks
!     for numbers that are zero.
!
!     INPUT:
!     IN1-3 = INTEGER VALUES TO BE PRINTED
!     FL1-6 = REAL VALUES TO BE PRINTED
!     CTYPE = CHARACTER STRING TO BE PRINTED
!
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER CTYPE*(*), CINT(3)*5, CFLT(6)*13
!
      DO 1 I=1,3
1     CINT(I)='     '
      IF(IN1.EQ.0.AND.IN2.EQ.0.AND.IN3.EQ.0)THEN
         CINT(1)='  ALL'
      ELSE
         IF(IN1.NE.0)WRITE(CINT(1),90)IN1
         IF(IN2.NE.0)WRITE(CINT(2),90)IN2
         IF(IN3.NE.0)WRITE(CINT(3),90)IN3
      END IF
      DO 2 I=1,6
2     CFLT(I)='     '
      IF(ABS(FL1).GT.1.E-30)WRITE(CFLT(1),91)FL1
      IF(ABS(FL2).GT.1.E-30)WRITE(CFLT(2),91)FL2
      IF(ABS(FL3).GT.1.E-30)WRITE(CFLT(3),91)FL3
      IF(ABS(FL4).GT.1.E-30)WRITE(CFLT(4),91)FL4
      IF(ABS(FL5).GT.1.E-30)WRITE(CFLT(5),91)FL5
      IF(ABS(FL6).GT.1.E-30)WRITE(CFLT(6),91)FL6
      WRITE(3,92)(CINT(I),I=1,3),(CFLT(I),I=1,6),CTYPE
      RETURN
!
90    FORMAT(I5)
91    FORMAT(1P,E13.4)
92    FORMAT(/,3X,3A,3X,6A,3X,A)
      END

!----------------------------------------------------------------------------

      SUBROUTINE QDSRC (IS,V,E)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     FILL INCIDENT FIELD ARRAY FOR CHARGE DISCONTINUITY VOLTAGE SOURCE
      COMPLEX*16 VQDS,CURD,CCJ,V,EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC
     1,ETK,ETS,ETC,VSANT,VQD,E,ZARRAY
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM

      COMMON /VSORC/ VQD(nsmax),VSANT(nsmax),VQDS(nsmax),IVQD(nsmax),
     &ISANT(nsmax),IQDS(nsmax),NVQD,NSANT,NQDS			! av07

      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      COMMON /ANGL/ SALP(MAXSEG)
      COMMON /ZLOAD/ ZARRAY(MAXSEG),NLOAD,NLODF
      DIMENSION CCJX(2), E(1), CAB(1), SAB(1)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1)
      EQUIVALENCE (CCJ,CCJX), (CAB,ALP), (SAB,BET)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG)
      DATA TP/6.283185308D+0/,CCJX/0.,-.01666666667D+0/

      I=ICON1(IS)
      ICON1(IS)=0
      CALL TBF (IS,0)
      ICON1(IS)=I
      S=SI(IS)*.5
      CURD=CCJ*V/((LOG(2.*S/BI(IS))-1.)*(BX(JSNO)*COS(TP*S)+CX(JSNO)*SI
     1N(TP*S))*WLAM)
      NQDS=NQDS+1
      VQDS(NQDS)=V
      IQDS(NQDS)=IS
      DO 20 JX=1,JSNO
      J=JCO(JX)
      S=SI(J)
      B=BI(J)
      XJ=X(J)
      YJ=Y(J)
      ZJ=Z(J)
      CABJ=CAB(J)
      SABJ=SAB(J)
      SALPJ=SALP(J)
      IF (IEXK.EQ.0) GO TO 16

      IPR=ICON1(J)
      IF(IPR.GT.10000)GO TO 7     !<---NEW, av016
      IF (IPR) 1,6,2

1     IPR=-IPR
      IF (-ICON1(IPR).NE.J) GO TO 7
      GO TO 4
2     IF (IPR.NE.J) GO TO 3
      IF (CABJ*CABJ+SABJ*SABJ.GT.1.D-8) GO TO 7
      GO TO 5
3     IF (ICON2(IPR).NE.J) GO TO 7
4     XI=ABS(CABJ*CAB(IPR)+SABJ*SAB(IPR)+SALPJ*SALP(IPR))
      IF (XI.LT.0.999999D+0) GO TO 7
      IF (ABS(BI(IPR)/B-1.).GT.1.D-6) GO TO 7
5     IND1=0
      GO TO 8
6     IND1=1
      GO TO 8
7     IND1=2

8     IPR=ICON2(J)
      IF(IPR.GT.10000)GO TO 15      !<---NEW, av016
      IF (IPR) 9,14,10

9     IPR=-IPR
      IF (-ICON2(IPR).NE.J) GO TO 15
      GO TO 12
10    IF (IPR.NE.J) GO TO 11
      IF (CABJ*CABJ+SABJ*SABJ.GT.1.D-8) GO TO 15
      GO TO 13
11    IF (ICON1(IPR).NE.J) GO TO 15
12    XI=ABS(CABJ*CAB(IPR)+SABJ*SAB(IPR)+SALPJ*SALP(IPR))
      IF (XI.LT.0.999999D+0) GO TO 15
      IF (ABS(BI(IPR)/B-1.).GT.1.D-6) GO TO 15
13    IND2=0
      GO TO 16
14    IND2=1
      GO TO 16
15    IND2=2
16    CONTINUE
      DO 17 I=1,N
      IJ=I-J
      XI=X(I)
      YI=Y(I)
      ZI=Z(I)
      AI=BI(I)
      CALL EFLD (XI,YI,ZI,AI,IJ)
      CABI=CAB(I)
      SABI=SAB(I)
      SALPI=SALP(I)
      ETK=EXK*CABI+EYK*SABI+EZK*SALPI
      ETS=EXS*CABI+EYS*SABI+EZS*SALPI
      ETC=EXC*CABI+EYC*SABI+EZC*SALPI
17    E(I)=E(I)-(ETK*AX(JX)+ETS*BX(JX)+ETC*CX(JX))*CURD
      IF (M.EQ.0) GO TO 19
      IJ=LD+1
      I1=N
      DO 18 I=1,M
      IJ=IJ-1
      XI=X(IJ)
      YI=Y(IJ)
      ZI=Z(IJ)
      CALL HSFLD (XI,YI,ZI,0.D0)
      I1=I1+1
      TX=T2X(IJ)
      TY=T2Y(IJ)
      TZ=T2Z(IJ)
      ETK=EXK*TX+EYK*TY+EZK*TZ
      ETS=EXS*TX+EYS*TY+EZS*TZ
      ETC=EXC*TX+EYC*TY+EZC*TZ
      E(I1)=E(I1)+(ETK*AX(JX)+ETS*BX(JX)+ETC*CX(JX))*CURD*SALP(IJ)
      I1=I1+1
      TX=T1X(IJ)
      TY=T1Y(IJ)
      TZ=T1Z(IJ)
      ETK=EXK*TX+EYK*TY+EZK*TZ
      ETS=EXS*TX+EYS*TY+EZS*TZ
      ETC=EXC*TX+EYC*TY+EZC*TZ
18    E(I1)=E(I1)+(ETK*AX(JX)+ETS*BX(JX)+ETC*CX(JX))*CURD*SALP(IJ)
19    IF (NLOAD.GT.0.OR.NLODF.GT.0) E(J)=E(J)+ZARRAY(J)*CURD*(AX(JX)+CX(
     1JX))
20    CONTINUE
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE RDPAT
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      PARAMETER(NORMAX=4*MAXSEG)
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     COMPUTE RADIATION PATTERN, GAIN, NORMALIZED GAIN
      REAL*8 IGNTP,IGAX,IGTP,HCIR,HBLK,HPOL,HCLIF,ISENS
!     INTEGER HPOL,HBLK,HCIR,HCLIF
      COMPLEX*16 ETH,EPH,ERD,ZRATI,ZRATI2,T1,FRATI
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON/SAVE/EPSR,SIG,SCRWLT,SCRWRT,FMHZ,IP(2*MAXSEG),KCOM
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      COMMON/FPAT/THETS,PHIS,DTH,DPH,RFLD,GNOR,CLT,CHT,EPSR2,SIG2,
     &XPR6,PINR,PNLR,PLOSS,XNR,YNR,ZNR,DXNR,DYNR,DZNR,NTH,NPH,IPD,IAVP,
     &INOR,IAX,IXTYP,NEAR,NFEH,NRX,NRY,NRZ
      COMMON /SCRATM/ GAIN(NORMAX)
!***
      COMMON /PLOT/ IPLP1,IPLP2,IPLP3,IPLP4
!***
      DIMENSION IGTP(4), IGAX(4), IGNTP(10), HPOL(3)
      DATA HPOL/6HLINEAR,5HRIGHT,4HLEFT/,HBLK,HCIR/1H ,6HCIRCLE/
      DATA IGTP/6H    - ,6HPOWER ,6H- DIRE,6HCTIVE /
      DATA IGAX/6H MAJOR,6H MINOR,6H VERT.,6H HOR. /
      DATA IGNTP/6H MAJOR,6H AXIS ,6H MINOR,6H AXIS ,6H   VER,6HTICAL ,6
     1H HORIZ,6HONTAL ,6H      ,6HTOTAL /
      DATA PI,TA,TD/3.141592654D+0,1.745329252D-02,57.29577951D+0/
      IF (IFAR.LT.2) GO TO 2
      WRITE(3,35)
      IF (IFAR.LE.3) GO TO 1
      WRITE(3,36)  NRADL,SCRWLT,SCRWRT
      IF (IFAR.EQ.4) GO TO 2
1     IF (IFAR.EQ.2.OR.IFAR.EQ.5) HCLIF=HPOL(1)
      IF (IFAR.EQ.3.OR.IFAR.EQ.6) HCLIF=HCIR
      CL=CLT/WLAM
      CH=CHT/WLAM
      ZRATI2=SQRT(1./DCMPLX(EPSR2,-SIG2*WLAM*59.96))
      WRITE(3,37)  HCLIF,CLT,CHT,EPSR2,SIG2
2     IF (IFAR.NE.1) GO TO 3
      WRITE(3,41)
      GO TO 5
3     I=2*IPD+1
      J=I+1
      ITMP1=2*IAX+1
      ITMP2=ITMP1+1
      WRITE(3,38)
      IF (RFLD.LT.1.D-20) GO TO 4
      EXRM=1./RFLD
      EXRA=RFLD/WLAM
      EXRA=-360.*(EXRA-AINT(EXRA))
      WRITE(3,39)  RFLD,EXRM,EXRA
4     WRITE(3,40)  IGTP(I),IGTP(J),IGAX(ITMP1),IGAX(ITMP2)
5     IF (IXTYP.EQ.0.OR.IXTYP.EQ.5) GO TO 7
      IF (IXTYP.EQ.4) GO TO 6
      PRAD=0.
      GCON=4.*PI/(1.+XPR6*XPR6)
      GCOP=GCON
      GO TO 8
6     PINR=394.51*XPR6*XPR6*WLAM*WLAM
7     GCOP=WLAM*WLAM*2.*PI/(376.73*PINR)
      PRAD=PINR-PLOSS-PNLR
      GCON=GCOP
      IF (IPD.NE.0) GCON=GCON*PINR/PRAD
8     I=0
      GMAX=-1.E10
      PINT=0.
      TMP1=DPH*TA
      TMP2=.5*DTH*TA
      PHI=PHIS-DPH
      DO 29 KPH=1,NPH
      PHI=PHI+DPH
      PHA=PHI*TA
      THET=THETS-DTH
      DO 29 KTH=1,NTH
      THET=THET+DTH
      IF (KSYMP.EQ.2.AND.THET.GT.90.01.AND.IFAR.NE.1) GO TO 29
      THA=THET*TA
      IF (IFAR.EQ.1) GO TO 9
      CALL FFLD (THA,PHA,ETH,EPH)
      GO TO 10
9     CALL GFLD (RFLD/WLAM,PHA,THET/WLAM,ETH,EPH,ERD,ZRATI,KSYMP)
      ERDM=ABS(ERD)
      ERDA=CANG(ERD)
10    ETHM2=DREAL(ETH*DCONJG(ETH))
      ETHM=SQRT(ETHM2)
      ETHA=CANG(ETH)
      EPHM2=DREAL(EPH*DCONJG(EPH))
      EPHM=SQRT(EPHM2)
      EPHA=CANG(EPH)
      IF (IFAR.EQ.1) GO TO 28
!     ELLIPTICAL POLARIZATION CALC.
      IF (ETHM2.GT.1.D-20.OR.EPHM2.GT.1.D-20) GO TO 11
      TILTA=0.
      EMAJR2=0.
      EMINR2=0.
      AXRAT=0.
      ISENS=HBLK
      GO TO 16
11    DFAZ=EPHA-ETHA
      IF (EPHA.LT.0.) GO TO 12
      DFAZ2=DFAZ-360.
      GO TO 13
12    DFAZ2=DFAZ+360.
13    IF (ABS(DFAZ).GT.ABS(DFAZ2)) DFAZ=DFAZ2
      CDFAZ=COS(DFAZ*TA)
      TSTOR1=ETHM2-EPHM2
      TSTOR2=2.*EPHM*ETHM*CDFAZ
      TILTA=.5*ATGN2(TSTOR2,TSTOR1)
      STILTA=SIN(TILTA)
      TSTOR1=TSTOR1*STILTA*STILTA
      TSTOR2=TSTOR2*STILTA*COS(TILTA)
      EMAJR2=-TSTOR1+TSTOR2+ETHM2
      EMINR2=TSTOR1-TSTOR2+EPHM2
      IF (EMINR2.LT.0.) EMINR2=0.
      AXRAT=SQRT(EMINR2/EMAJR2)
      TILTA=TILTA*TD
      IF (AXRAT.GT.1.D-5) GO TO 14
      ISENS=HPOL(1)
      GO TO 16
14    IF (DFAZ.GT.0.) GO TO 15
      ISENS=HPOL(2)
      GO TO 16
15    ISENS=HPOL(3)
16    GNMJ=DB10(GCON*EMAJR2)
      GNMN=DB10(GCON*EMINR2)
      GNV=DB10(GCON*ETHM2)
      GNH=DB10(GCON*EPHM2)
      GTOT=DB10(GCON*(ETHM2+EPHM2))
      IF (INOR.LT.1) GO TO 23
      I=I+1
      IF (I.GT.NORMAX) GO TO 23
      GO TO (17,18,19,20,21), INOR
17    TSTOR1=GNMJ
      GO TO 22
18    TSTOR1=GNMN
      GO TO 22
19    TSTOR1=GNV
      GO TO 22
20    TSTOR1=GNH
      GO TO 22
21    TSTOR1=GTOT
22    GAIN(I)=TSTOR1
      IF (TSTOR1.GT.GMAX) GMAX=TSTOR1
23    IF (IAVP.EQ.0) GO TO 24
      TSTOR1=GCOP*(ETHM2+EPHM2)
      TMP3=THA-TMP2
      TMP4=THA+TMP2
      IF (KTH.EQ.1) TMP3=THA
      IF (KTH.EQ.NTH) TMP4=THA
      DA=ABS(TMP1*(COS(TMP3)-COS(TMP4)))
      IF (KPH.EQ.1.OR.KPH.EQ.NPH) DA=.5*DA
      PINT=PINT+TSTOR1*DA
      IF (IAVP.EQ.2) GO TO 29
24    IF (IAX.EQ.1) GO TO 25
      TMP5=GNMJ
      TMP6=GNMN
      GO TO 26
25    TMP5=GNV
      TMP6=GNH
26    ETHM=ETHM*WLAM
      EPHM=EPHM*WLAM
      IF (RFLD.LT.1.D-20) GO TO 27
      ETHM=ETHM*EXRM
      ETHA=ETHA+EXRA
      EPHM=EPHM*EXRM
      EPHA=EPHA+EXRA
27    WRITE(3,42)  THET,PHI,TMP5,TMP6,GTOT,AXRAT,TILTA,ISENS,ETHM,ETHA
     1,EPHM,EPHA
!      GO TO 29
!***
!28    WRITE(3,43)  RFLD,PHI,THET,ETHM,ETHA,EPHM,EPHA,ERDM,ERDA
      IF(IPLP1 .NE. 3) GO TO 299
      IF(IPLP3 .EQ. 0) GO TO 290
      IF(IPLP2 .EQ. 1 .AND. IPLP3 .EQ. 1)
     1WRITE(8,*) THET,ETHM,ETHA
      IF(IPLP2 .EQ. 1 .AND. IPLP3 .EQ. 2)
     1WRITE(8,*) THET,EPHM,EPHA
      IF(IPLP2 .EQ. 2 .AND. IPLP3 .EQ. 1)
     1WRITE(8,*) PHI,ETHM,ETHA
      IF(IPLP2 .EQ. 2 .AND. IPLP3 .EQ. 2)
     1WRITE(8,*) PHI,EPHM,EPHA
      IF(IPLP4 .EQ. 0) GO TO 299
290   IF(IPLP2 .EQ. 1 .AND. IPLP4 .EQ. 1)
     1WRITE(8,*) THET,TMP5
      IF(IPLP2 .EQ. 1 .AND. IPLP4 .EQ. 2)
     1WRITE(8,*) THET,TMP6
      IF(IPLP2 .EQ. 1 .AND. IPLP4 .EQ. 3)
     1WRITE(8,*) THET,GTOT
      IF(IPLP2 .EQ. 2 .AND. IPLP4 .EQ. 1)
     1WRITE(8,*) PHI,TMP5
      IF(IPLP2 .EQ. 2 .AND. IPLP4 .EQ. 2)
     1WRITE(8,*) PHI,TMP6
      IF(IPLP2 .EQ. 2 .AND. IPLP4 .EQ. 3)
     1WRITE(8,*) PHI,GTOT
      GO TO 299
28    WRITE(3,43)  RFLD,PHI,THET,ETHM,ETHA,EPHM,EPHA,ERDM,ERDA
299   CONTINUE
!***
29    CONTINUE
      IF (IAVP.EQ.0) GO TO 30
      TMP3=THETS*TA
      TMP4=TMP3+DTH*TA*DFLOAT(NTH-1)
      TMP3=ABS(DPH*TA*DFLOAT(NPH-1)*(COS(TMP3)-COS(TMP4)))
      PINT=PINT/TMP3
      TMP3=TMP3/PI
      WRITE(3,44)  PINT,TMP3
30    IF (INOR.EQ.0) GO TO 34
      IF (ABS(GNOR).GT.1.D-20) GMAX=GNOR
      ITMP1=(INOR-1)*2+1
      ITMP2=ITMP1+1
      WRITE(3,45)  IGNTP(ITMP1),IGNTP(ITMP2),GMAX
      ITMP2=NPH*NTH
      IF (ITMP2.GT.NORMAX) ITMP2=NORMAX
      ITMP1=(ITMP2+2)/3
      ITMP2=ITMP1*3-ITMP2
      ITMP3=ITMP1
      ITMP4=2*ITMP1
      IF (ITMP2.EQ.2) ITMP4=ITMP4-1
      DO 31 I=1,ITMP1
      ITMP3=ITMP3+1
      ITMP4=ITMP4+1
      J=(I-1)/NTH
      TMP1=THETS+DFLOAT(I-J*NTH-1)*DTH
      TMP2=PHIS+DFLOAT(J)*DPH
      J=(ITMP3-1)/NTH
      TMP3=THETS+DFLOAT(ITMP3-J*NTH-1)*DTH
      TMP4=PHIS+DFLOAT(J)*DPH
      J=(ITMP4-1)/NTH
      TMP5=THETS+DFLOAT(ITMP4-J*NTH-1)*DTH
      TMP6=PHIS+DFLOAT(J)*DPH
      TSTOR1=GAIN(I)-GMAX
      IF (I.EQ.ITMP1.AND.ITMP2.NE.0) GO TO 32
      TSTOR2=GAIN(ITMP3)-GMAX
      PINT=GAIN(ITMP4)-GMAX
31    WRITE(3,46)  TMP1,TMP2,TSTOR1,TMP3,TMP4,TSTOR2,TMP5,TMP6,PINT
      GO TO 34
32    IF (ITMP2.EQ.2) GO TO 33
      TSTOR2=GAIN(ITMP3)-GMAX
      WRITE(3,46)  TMP1,TMP2,TSTOR1,TMP3,TMP4,TSTOR2
      GO TO 34
33    WRITE(3,46)  TMP1,TMP2,TSTOR1
34    RETURN
!
35    FORMAT (///,31X,39H- - - FAR FIELD GROUND PARAMETERS - - -,//)
36    FORMAT (40X,25HRADIAL WIRE GROUND SCREEN,/,40X,I5,6H WIRES,/,40X,1
     12HWIRE LENGTH=,F8.2,7H METERS,/,40X,12HWIRE RADIUS=,1P,E10.3,
     27H METERS)
37    FORMAT (40X,A6,6H CLIFF,/,40X,14HEDGE DISTANCE=,F9.2,7H METERS,/,4
     10X,7HHEIGHT=,F8.2,7H METERS,/,40X,15HSECOND MEDIUM -,/,40X,27HRELA
     2TIVE DIELECTRIC CONST.=,F7.3,/,40X,13HCONDUCTIVITY=,1P,E10.3,
     35H MHOS)
38    FORMAT (///,48X,30H- - - RADIATION PATTERNS - - -)
39    FORMAT (54X,6HRANGE=,1P,E13.6,7H METERS,/,54X,12HEXP(-JKR)/R=,
     1E12.5,9H AT PHASE,0P,F7.2,8H DEGREES,/)
40    FORMAT (/,2X,14H- - ANGLES - -,7X,2A6,7HGAINS -,7X,24H- - - POLARI
     1ZATION - - -,4X,20H- - - E(THETA) - - -,4X,18H- - - E(PHI) - - -,
     2/,2X,5HTHETA,5X,3HPHI,7X,A6,2X,A6,3X,5HTOTAL,6X,5HAXIAL,5X,4HTILT,
     33X,5HSENSE,2(5X,9HMAGNITUDE,4X,6HPHASE ),/,2(1X,7HDEGREES,1X),3(
     46X,2HDB),8X,5HRATIO,5X,4HDEG.,8X,2(6X,7HVOLTS/M,4X,7HDEGREES))
41    FORMAT (///,28X,40H - - - RADIATED FIELDS NEAR GROUND - - -,//,8X,
     120H- - - LOCATION - - -,10X,16H- - E(THETA) - -,8X,14H- - E(PHI) -
     2 -,8X,17H- - E(RADIAL) - -,/,7X,3HRHO,6X,3HPHI,9X,1HZ,12X,3HMAG,6X
     3,5HPHASE,9X,3HMAG,6X,5HPHASE,9X,3HMAG,6X,5HPHASE,/,5X,6HMETERS,3X,
     47HDEGREES,4X,6HMETERS,8X,7HVOLTS/M,3X,7HDEGREES,6X,7HVOLTS/M,3X,7H
     5DEGREES,6X,7HVOLTS/M,3X,7HDEGREES,/)
42    FORMAT(1X,F7.2,F9.2,3X,3F8.2,F11.5,F9.2,2X,A6,2(1P,E15.5,0P,F9.2))
43    FORMAT (3X,F9.2,2X,F7.2,2X,F9.2,1X,3(3X,1P,E11.4,2X,0P,F7.2))
44    FORMAT (//,3X,19HAVERAGE POWER GAIN=,1P,E12.5,7X, 31HSOLID ANGLE U
     1SED IN AVERAGING=(,0P,F7.4,16H)*PI STERADIANS.,//)
45    FORMAT (//,37X,31H- - - - NORMALIZED GAIN - - - -,//,37X,2A6,4HGAI
     1N,/,38X,22HNORMALIZATION FACTOR =,F9.2,3H DB,//,3(4X,14H- - ANGLES
     2 - -,6X,4HGAIN,7X),/,3(4X,5HTHETA,5X,3HPHI,8X,2HDB,8X),/,3(3X,7HDE
     3GREES,2X,7HDEGREES,16X))
46    FORMAT (3(1X,2F9.2,1X,F9.2,6X))
      END
!----------------------------------------------------------------------------

      SUBROUTINE READGM(INUNIT,CODE,I1,I2,R1,R2,R3,R4,R5,R6,R7)
!
!  READGM reads a geometry record and parses it.
!
!  *****  Passed variables
!     CODE        two letter mnemonic code
!     I1 - I2     integer values from record
!     R1 - R7     real values from record
!
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*(*) CODE
      DIMENSION INTVAL(2),REAVAL(7)
!
!  Call the routine to read the record and parse it.
!
      CALL PARSIT(INUNIT,2,7,CODE,INTVAL,REAVAL,IEOF)
!
!  Set the return variables to the buffer array elements.
!
      IF(IEOF.LT.0)CODE='GE'
      I1=INTVAL(1)
      I2=INTVAL(2)
      R1=REAVAL(1)
      R2=REAVAL(2)
      R3=REAVAL(3)
      R4=REAVAL(4)
      R5=REAVAL(5)
      R6=REAVAL(6)
      R7=REAVAL(7)
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE READMN(INUNIT,CODE,I1,I2,I3,I4,F1,F2,F3,F4,F5,F6)
!
!  READMN reads a control record and parses it.
!
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*(*) CODE
      DIMENSION INTVAL(4),REAVAL(6)
!
!  Call the routine to read the record and parse it.
!
      CALL PARSIT(INUNIT,4,6,CODE,INTVAL,REAVAL,IEOF)
!
!  Set the return variables to the buffer array elements.
      IF(IEOF.LT.0)CODE='EN'
      I1=INTVAL(1)
      I2=INTVAL(2)
      I3=INTVAL(3)
      I4=INTVAL(4)
      F1=REAVAL(1)
      F2=REAVAL(2)
      F3=REAVAL(3)
      F4=REAVAL(4)
      F5=REAVAL(5)
      F6=REAVAL(6)
      RETURN
      END



!----------------------------------------------------------------------------

      SUBROUTINE PARSIT(INUNIT,MAXINT,MAXREA,CMND,INTFLD,REAFLD,IEOF)

!  UPDATED:  21 July 87

!  Called by:   READGM    READMN

!  PARSIT reads an input record and parses it.

!  *****  Passed variables
!     MAXINT     total number of integers in record
!     MAXREA     total number of real values in record
!     CMND       two letter mnemonic code
!     INTFLD     integer values from record
!     REAFLD     real values from record

!  *****  Internal Variables
!     BGNFLD     list of starting indices
!     BUFFER     text buffer
!     ENDFLD     list of ending indices
!     FLDTRM     flag to indicate that pointer is in field position
!     REC        input line as read
!     TOTCOL     total number of columns in REC
!     TOTFLD     number of numeric fields

      IMPLICIT REAL*8(A-H,O-Z)

!  *****  Global variables		! av12
	character*80 ngfnam		! av12
	common /ngfnam/ ngfnam		! av12

      CHARACTER  CMND*2, BUFFER*20, REC*80
      INTEGER    INTFLD(MAXINT)
      INTEGER    BGNFLD(12), ENDFLD(12), TOTCOL, TOTFLD
      LOGICAL    FLDTRM
      DIMENSION  REAFLD(MAXREA)
!
      READ(INUNIT, 8000, IOSTAT=IEOF) REC
      CALL UPCASE( REC, REC, TOTCOL )

!
!  Store opcode and clear field arrays.
!
      CMND= REC(1:2)
      DO 3000 I=1,MAXINT
           INTFLD(I)= 0
 3000 CONTINUE
      DO 3010 I=1,MAXREA
           REAFLD(I)= 0.0
 3010 CONTINUE
      DO 3020 I=1,12
           BGNFLD(I)= 0
           ENDFLD(I)= 0
 3020 CONTINUE

!
!  Find the beginning and ending of each field as well as the total number of
!  fields.
!
      TOTFLD= 0
      FLDTRM= .FALSE.
      LAST= MAXREA + MAXINT
      DO 4000 J=3,TOTCOL
           K= ICHAR( REC(J:J) )
!
!  Check for end of line comment (`!').  This is a new modification to allow
!  VAX-like comments at the end of data records, i.e.
!       GW 1 7 0 0 0 0 0 .5 .0001 ! DIPOLE WIRE
!       GE ! END OF GEOMETRY
!
      IF (K .EQ. 33) THEN					! .eq. '!'
         IF (FLDTRM) ENDFLD(TOTFLD)= J - 1
         GO TO 5000
!
!  Set the ending index when the character is a comma or space and the pointer
!  is in a field position (FLDTRM = .TRUE.).
!
          ELSE IF (K .EQ. 32  .OR.  K .EQ. 44) THEN	! space or comma ?
             IF (FLDTRM) THEN
                ENDFLD(TOTFLD)= J - 1
                FLDTRM= .FALSE.
             ENDIF
!
!  Set the beginning index when the character is not a comma or space and the
!  pointer is not currently in a field position (FLDTRM = .FALSE).
!
          ELSE IF (.NOT. FLDTRM) THEN
              TOTFLD= TOTFLD + 1
              FLDTRM= .TRUE.
              BGNFLD(TOTFLD)= J
          ENDIF
 4000   CONTINUE
        IF (FLDTRM) ENDFLD(TOTFLD)= TOTCOL

!  Check to see if the total number of value fields is within the precribed
!  limits.

 5000	if ((cmnd.eq.'WG').or.(cmnd.eq.'GF')) then	! Init default NGFNAM
	   ngfnam='NGF2D.NEC' 				! av15
        endif
	IF (TOTFLD .EQ. 0) THEN
             RETURN
        ELSE IF (TOTFLD .GT. LAST) THEN
             WRITE(3, 8001 )
             GOTO 9010
        ENDIF
        J= MIN( TOTFLD, MAXINT )

!  Parse out integer values and store into integer buffer array.

        DO 5090 I=1,J
             LENGTH= ENDFLD(I) - BGNFLD(I) + 1
             BUFFER= REC(BGNFLD(I):ENDFLD(I))

	if (((cmnd.eq.'WG').or.(cmnd.eq.'GF')).and.
     &  (buffer(1:1).ne.'0') .and. (buffer(1:1).ne.'1')) then	! Text field, av12
	   ngfnam = rec(bgnfld(i):endfld(i))			! av12
	   return								! av12
	endif									! av12

             IND= INDEX( BUFFER(1:LENGTH), '.' )
             IF (IND .GT. 0  .AND.  IND .LT. LENGTH) GO TO 9000
             IF (IND .EQ. LENGTH) LENGTH= LENGTH - 1
             READ( BUFFER(1:LENGTH), *, ERR=9000 ) INTFLD(I)
 5090   CONTINUE

!  Parse out real values and store into real buffer array.

        IF (TOTFLD .GT. MAXINT) THEN
             J= MAXINT + 1
             DO 6000 I=J,TOTFLD
                  LENGTH= ENDFLD(I) - BGNFLD(I) + 1
                  BUFFER= REC(BGNFLD(I):ENDFLD(I))
                  IND= INDEX( BUFFER(1:LENGTH), '.' )
                  IF (IND .EQ. 0) THEN
                       INDE= INDEX( BUFFER(1:LENGTH), 'E' )
                       LENGTH= LENGTH + 1
                       IF (INDE .EQ. 0) THEN
                            BUFFER(LENGTH:LENGTH)= '.'
                       ELSE
                            BUFFER= BUFFER(1:INDE-1)//'.'//
     &                               BUFFER(INDE:LENGTH-1)
                       ENDIF
                  ENDIF
                  READ( BUFFER(1:LENGTH), *, ERR=9000 ) REAFLD(I-MAXINT)
 6000        CONTINUE
        ENDIF
        RETURN

!  Print out text of record line when error occurs.

 9000   IF (I .LE. MAXINT) THEN
             WRITE(3, 8002 ) I
        ELSE
             I= I - MAXINT
             WRITE(3, 8003 ) I
        ENDIF
 9010   WRITE(3, 8004 ) REC
        STOP 'CARD ERROR'
!
!  Input formats and output messages.
!
 8000   FORMAT (A80)
 8001   FORMAT (//,' ***** CARD ERROR - TOO MANY FIELDS IN RECORD')
 8002   FORMAT (//,' ***** CARD ERROR - INVALID NUMBER AT INTEGER',
     &          ' POSITION ',I1)
 8003   FORMAT (//,' ***** CARD ERROR - INVALID NUMBER AT REAL',
     &          ' POSITION ',I1)
 8004   FORMAT (' ***** TEXT -->  ',A80)
        END
!----------------------------------------------------------------------------

        SUBROUTINE UPCASE( INTEXT, OUTTXT, LENGTH )
!
!  UPCASE finds the length of INTEXT and converts it to upper case.
!
        CHARACTER *(*) INTEXT, OUTTXT
!
!
        LENGTH = LEN( INTEXT )
        DO 3000 I=1,LENGTH
             J  = ICHAR( INTEXT(I:I) )
             IF (J .GE. 96) J = J - 32
             OUTTXT(I:I) = CHAR( J )
 3000   CONTINUE
        RETURN
        END
!----------------------------------------------------------------------------

      SUBROUTINE REBLK (B,BX,NB,NBX,N2C)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     REBLOCK ARRAY B IN N.G.F. SOLUTION FROM BLOCKS OF ROWS ON TAPE14
!     TO BLOCKS OF COLUMNS ON TAPE16
      COMPLEX*16 B,BX
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      DIMENSION B(NB,1), BX(NBX,1)
      REWIND 16
      NIB=0
      NPB=NPBL
      DO 3 IB=1,NBBL
      IF (IB.EQ.NBBL) NPB=NLBL
      REWIND 14
      NIX=0
      NPX=NPBX
      DO 2 IBX=1,NBBX
      IF (IBX.EQ.NBBX) NPX=NLBX
      READ (14) ((BX(I,J),I=1,NPX),J=1,N2C)
      DO 1 I=1,NPX
      IX=I+NIX
      DO 1 J=1,NPB
1     B(IX,J)=BX(I,J+NIB)
2     NIX=NIX+NPBX
      WRITE (16) ((B(I,J),I=1,NB),J=1,NPB)
3     NIB=NIB+NPBL
      REWIND 14
      REWIND 16
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE REFLC (IX,IY,IZ,ITX,NOP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     REFLC REFLECTS PARTIAL STRUCTURE ALONG X,Y, OR Z AXES OR ROTATES
!     STRUCTURE TO COMPLETE A SYMMETRIC STRUCTURE.
!
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      COMMON /ANGL/ SALP(MAXSEG)
      DIMENSION T1X(1), T1Y(1), T1Z(1), T2X(1), T2Y(1), T2Z(1), X2(1), Y
     12(1), Z2(1)
      EQUIVALENCE (T1X,SI), (T1Y,ALP), (T1Z,BET), (T2X,ICON1), (T2Y,ICON
     12), (T2Z,ITAG), (X2,SI), (Y2,ALP), (Z2,BET)
      NP=N
      MP=M
      IPSYM=0
      ITI=ITX
      IF (IX.LT.0) GO TO 19
      IF (NOP.EQ.0) RETURN
      IPSYM=1
      IF (IZ.EQ.0) GO TO 6
!
!     REFLECT ALONG Z AXIS
!
      IPSYM=2
      IF (N.LT.N2) GO TO 3
      DO 2 I=N2,N
      NX=I+N-N1
      E1=Z(I)
      E2=Z2(I)
      IF (ABS(E1)+ABS(E2).GT.1.D-5.AND.E1*E2.GE.-1.D-6) GO TO 1
      WRITE(3,24)  I
      STOP
1     X(NX)=X(I)
      Y(NX)=Y(I)
      Z(NX)=-E1
      X2(NX)=X2(I)
      Y2(NX)=Y2(I)
      Z2(NX)=-E2
      ITAGI=ITAG(I)
      IF (ITAGI.EQ.0) ITAG(NX)=0
      IF (ITAGI.NE.0) ITAG(NX)=ITAGI+ITI
2     BI(NX)=BI(I)
      N=N*2-N1
      ITI=ITI*2
3     IF (M.LT.M2) GO TO 6
      NXX=LD+1-M1
      DO 5 I=M2,M
      NXX=NXX-1
      NX=NXX-M+M1
      IF (ABS(Z(NXX)).GT.1.D-10) GO TO 4
      WRITE(3,25)  I
      STOP
4     X(NX)=X(NXX)
      Y(NX)=Y(NXX)
      Z(NX)=-Z(NXX)
      T1X(NX)=T1X(NXX)
      T1Y(NX)=T1Y(NXX)
      T1Z(NX)=-T1Z(NXX)
      T2X(NX)=T2X(NXX)
      T2Y(NX)=T2Y(NXX)
      T2Z(NX)=-T2Z(NXX)
      SALP(NX)=-SALP(NXX)
5     BI(NX)=BI(NXX)
      M=M*2-M1
6     IF (IY.EQ.0) GO TO 12
!
!     REFLECT ALONG Y AXIS
!
      IF (N.LT.N2) GO TO 9
      DO 8 I=N2,N
      NX=I+N-N1
      E1=Y(I)
      E2=Y2(I)
      IF (ABS(E1)+ABS(E2).GT.1.D-5.AND.E1*E2.GE.-1.D-6) GO TO 7
      WRITE(3,24)  I
      STOP
7     X(NX)=X(I)
      Y(NX)=-E1
      Z(NX)=Z(I)
      X2(NX)=X2(I)
      Y2(NX)=-E2
      Z2(NX)=Z2(I)
      ITAGI=ITAG(I)
      IF (ITAGI.EQ.0) ITAG(NX)=0
      IF (ITAGI.NE.0) ITAG(NX)=ITAGI+ITI
8     BI(NX)=BI(I)
      N=N*2-N1
      ITI=ITI*2
9     IF (M.LT.M2) GO TO 12
      NXX=LD+1-M1
      DO 11 I=M2,M
      NXX=NXX-1
      NX=NXX-M+M1
      IF (ABS(Y(NXX)).GT.1.D-10) GO TO 10
      WRITE(3,25)  I
      STOP
10    X(NX)=X(NXX)
      Y(NX)=-Y(NXX)
      Z(NX)=Z(NXX)
      T1X(NX)=T1X(NXX)
      T1Y(NX)=-T1Y(NXX)
      T1Z(NX)=T1Z(NXX)
      T2X(NX)=T2X(NXX)
      T2Y(NX)=-T2Y(NXX)
      T2Z(NX)=T2Z(NXX)
      SALP(NX)=-SALP(NXX)
11    BI(NX)=BI(NXX)
      M=M*2-M1
12    IF (IX.EQ.0) GO TO 18
!
!     REFLECT ALONG X AXIS
!
      IF (N.LT.N2) GO TO 15
      DO 14 I=N2,N
      NX=I+N-N1
      E1=X(I)
      E2=X2(I)
      IF (ABS(E1)+ABS(E2).GT.1.D-5.AND.E1*E2.GE.-1.D-6) GO TO 13
      WRITE(3,24)  I
      STOP
13    X(NX)=-E1
      Y(NX)=Y(I)
      Z(NX)=Z(I)
      X2(NX)=-E2
      Y2(NX)=Y2(I)
      Z2(NX)=Z2(I)
      ITAGI=ITAG(I)
      IF (ITAGI.EQ.0) ITAG(NX)=0
      IF (ITAGI.NE.0) ITAG(NX)=ITAGI+ITI
14    BI(NX)=BI(I)
      N=N*2-N1
15    IF (M.LT.M2) GO TO 18
      NXX=LD+1-M1
      DO 17 I=M2,M
      NXX=NXX-1
      NX=NXX-M+M1
      IF (ABS(X(NXX)).GT.1.D-10) GO TO 16
      WRITE(3,25)  I
      STOP
16    X(NX)=-X(NXX)
      Y(NX)=Y(NXX)
      Z(NX)=Z(NXX)
      T1X(NX)=-T1X(NXX)
      T1Y(NX)=T1Y(NXX)
      T1Z(NX)=T1Z(NXX)
      T2X(NX)=-T2X(NXX)
      T2Y(NX)=T2Y(NXX)
      T2Z(NX)=T2Z(NXX)
      SALP(NX)=-SALP(NXX)
17    BI(NX)=BI(NXX)
      M=M*2-M1
18    RETURN
!
!     REPRODUCE STRUCTURE WITH ROTATION TO FORM CYLINDRICAL STRUCTURE
!
19    FNOP=NOP
      IPSYM=-1
      SAM=6.283185308D+0/FNOP
      CS=COS(SAM)
      SS=SIN(SAM)
      IF (N.LT.N2) GO TO 21
      N=N1+(N-N1)*NOP
      NX=NP+1
      DO 20 I=NX,N
      K=I-NP+N1
      XK=X(K)
      YK=Y(K)
      X(I)=XK*CS-YK*SS
      Y(I)=XK*SS+YK*CS
      Z(I)=Z(K)
      XK=X2(K)
      YK=Y2(K)
      X2(I)=XK*CS-YK*SS
      Y2(I)=XK*SS+YK*CS
      Z2(I)=Z2(K)
      ITAGI=ITAG(K)
      IF (ITAGI.EQ.0) ITAG(I)=0
      IF (ITAGI.NE.0) ITAG(I)=ITAGI+ITI
20    BI(I)=BI(K)
21    IF (M.LT.M2) GO TO 23
      M=M1+(M-M1)*NOP
      NX=MP+1
      K=LD+1-M1
      DO 22 I=NX,M
      K=K-1
      J=K-MP+M1
      XK=X(K)
      YK=Y(K)
      X(J)=XK*CS-YK*SS
      Y(J)=XK*SS+YK*CS
      Z(J)=Z(K)
      XK=T1X(K)
      YK=T1Y(K)
      T1X(J)=XK*CS-YK*SS
      T1Y(J)=XK*SS+YK*CS
      T1Z(J)=T1Z(K)
      XK=T2X(K)
      YK=T2Y(K)
      T2X(J)=XK*CS-YK*SS
      T2Y(J)=XK*SS+YK*CS
      T2Z(J)=T2Z(K)
      SALP(J)=SALP(K)
22    BI(J)=BI(K)
23    RETURN
!
24    FORMAT (29H GEOMETRY DATA ERROR--SEGMENT,I5,26H LIES IN PLANE OF S
     1YMMETRY)
25    FORMAT (27H GEOMETRY DATA ERROR--PATCH,I4,26H LIES IN PLANE OF SYM
     1METRY)
      END
!----------------------------------------------------------------------------

      SUBROUTINE ROM2 (A,B,SUM,DMIN)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     FOR THE SOMMERFELD GROUND OPTION, ROM2 INTEGRATES OVER THE SOURCE
!     SEGMENT TO OBTAIN THE TOTAL FIELD DUE TO GROUND.  THE METHOD OF
!     VARIABLE INTERVAL WIDTH ROMBERG INTEGRATION IS USED.  THERE ARE 9
!     FIELD COMPONENTS - THE X, Y, AND Z COMPONENTS DUE TO CONSTANT,
!     SINE, AND COSINE CURRENT DISTRIBUTIONS.
!
      COMPLEX*16 SUM,G1,G2,G3,G4,G5,T00,T01,T10,T02,T11,T20
      DIMENSION SUM(9), G1(9), G2(9), G3(9), G4(9), G5(9), T01(9), T10(9
     1), T20(9)
      DATA NM,NTS,NX,N/65536,4,1,9/,RX/1.D-4/
      Z=A
      ZE=B
      S=B-A
      IF (S.GE.0.) GO TO 1
      WRITE(3,18)
      STOP
1     EP=S/(1.E4*NM)
      ZEND=ZE-EP
      DO 2 I=1,N
2     SUM(I)=(0.,0.)
      NS=NX
      NT=0
      CALL SFLDS (Z,G1)
3     DZ=S/NS
      IF (Z+DZ.LE.ZE) GO TO 4
      DZ=ZE-Z
      IF (DZ.LE.EP) GO TO 17
4     DZOT=DZ*.5
      CALL SFLDS (Z+DZOT,G3)
      CALL SFLDS (Z+DZ,G5)
5     TMAG1=0.
      TMAG2=0.
!
!     EVALUATE 3 POINT ROMBERG RESULT AND TEST CONVERGENCE.
!
      DO 6 I=1,N
      T00=(G1(I)+G5(I))*DZOT
      T01(I)=(T00+DZ*G3(I))*.5
      T10(I)=(4.*T01(I)-T00)/3.
      IF (I.GT.3) GO TO 6
      TR=DREAL(T01(I))
      TI=DIMAG(T01(I))
      TMAG1=TMAG1+TR*TR+TI*TI
      TR=DREAL(T10(I))
      TI=DIMAG(T10(I))
      TMAG2=TMAG2+TR*TR+TI*TI
6     CONTINUE
      TMAG1=SQRT(TMAG1)
      TMAG2=SQRT(TMAG2)
      CALL TEST(TMAG1,TMAG2,TR,0.D0,0.D0,TI,DMIN)
      IF(TR.GT.RX)GO TO 8
      DO 7 I=1,N
7     SUM(I)=SUM(I)+T10(I)
      NT=NT+2
      GO TO 12
8     CALL SFLDS (Z+DZ*.25,G2)
      CALL SFLDS (Z+DZ*.75,G4)
      TMAG1=0.
      TMAG2=0.
!
!     EVALUATE 5 POINT ROMBERG RESULT AND TEST CONVERGENCE.
!
      DO 9 I=1,N
      T02=(T01(I)+DZOT*(G2(I)+G4(I)))*.5
      T11=(4.*T02-T01(I))/3.
      T20(I)=(16.*T11-T10(I))/15.
      IF (I.GT.3) GO TO 9
      TR=DREAL(T11)
      TI=DIMAG(T11)
      TMAG1=TMAG1+TR*TR+TI*TI
      TR=DREAL(T20(I))
      TI=DIMAG(T20(I))
      TMAG2=TMAG2+TR*TR+TI*TI
9     CONTINUE
      TMAG1=SQRT(TMAG1)
      TMAG2=SQRT(TMAG2)
      CALL TEST(TMAG1,TMAG2,TR,0.D0,0.D0,TI,DMIN)
      IF(TR.GT.RX)GO TO 14
10    DO 11 I=1,N
11    SUM(I)=SUM(I)+T20(I)
      NT=NT+1
12    Z=Z+DZ
      IF (Z.GT.ZEND) GO TO 17
      DO 13 I=1,N
13    G1(I)=G5(I)
      IF (NT.LT.NTS.OR.NS.LE.NX) GO TO 3
      NS=NS/2
      NT=1
      GO TO 3
14    NT=0
      IF (NS.LT.NM) GO TO 15
      WRITE(3,19)  Z
      GO TO 10
15    NS=NS*2
      DZ=S/NS
      DZOT=DZ*.5
      DO 16 I=1,N
      G5(I)=G3(I)
16    G3(I)=G2(I)
      GO TO 5
17    CONTINUE
      RETURN
!
18    FORMAT (30H ERROR - B LESS THAN A IN ROM2)
19    FORMAT (33H ROM2 -- STEP SIZE LIMITED AT Z =,1P,E12.5)
      END
!----------------------------------------------------------------------------

      SUBROUTINE SBF (I,IS,AA,BB,CC)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     COMPUTE COMPONENT OF BASIS FUNCTION I ON SEGMENT IS.
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM

      DATA PI/3.141592654D+0/

      AA=0.
      BB=0.
      CC=0.
      JUNE=0
      JSNO=0
      PP=0.
      JCOX=ICON1(I)
      IF (JCOX.GT.10000) JCOX=I
      JEND=-1
      IEND=-1
      SIG=-1.
      IF (JCOX) 1,11,2
1     JCOX=-JCOX
      GO TO 3
2     SIG=-SIG
      JEND=-JEND
3     JSNO=JSNO+1
      IF (JSNO.GE.JMAX) GO TO 24
      D=PI*SI(JCOX)
      SDH=SIN(D)
      CDH=COS(D)
      SD=2.*SDH*CDH
      IF (D.GT.0.015) GO TO 4
      OMC=4.*D*D
      OMC=((1.3888889D-3*OMC-4.1666666667D-2)*OMC+.5)*OMC
      GO TO 5
4     OMC=1.-CDH*CDH+SDH*SDH
5     AJ=1./(LOG(1./(PI*BI(JCOX)))-.577215664D+0)
      PP=PP-OMC/SD*AJ
      IF (JCOX.NE.IS) GO TO 6
      AA=AJ/SD*SIG
      BB=AJ/(2.*CDH)
      CC=-AJ/(2.*SDH)*SIG
      JUNE=IEND
6     IF (JCOX.EQ.I) GO TO 9
      IF (JEND.EQ.1) GO TO 7
      JCOX=ICON1(JCOX)
      GO TO 8
7     JCOX=ICON2(JCOX)
8     IF (IABS(JCOX).EQ.I) GO TO 10
      IF (JCOX) 1,24,2
9     IF (JCOX.EQ.IS) BB=-BB
10    IF (IEND.EQ.1) GO TO 12
11    PM=-PP
      PP=0.
      NJUN1=JSNO
      JCOX=ICON2(I)
      IF (JCOX.GT.10000) JCOX=I
      JEND=1
      IEND=1
      SIG=-1.
      IF (JCOX) 1,12,2
12    NJUN2=JSNO-NJUN1
      D=PI*SI(I)
      SDH=SIN(D)
      CDH=COS(D)
      SD=2.*SDH*CDH
      CD=CDH*CDH-SDH*SDH
      IF (D.GT.0.015) GO TO 13
      OMC=4.*D*D
      OMC=((1.3888889D-3*OMC-4.1666666667D-2)*OMC+.5)*OMC
      GO TO 14
13    OMC=1.-CD
14    AP=1./(LOG(1./(PI*BI(I)))-.577215664D+0)
      AJ=AP
      IF (NJUN1.EQ.0) GO TO 19
      IF (NJUN2.EQ.0) GO TO 21
      QP=SD*(PM*PP+AJ*AP)+CD*(PM*AP-PP*AJ)
      QM=(AP*OMC-PP*SD)/QP
      QP=-(AJ*OMC+PM*SD)/QP
      IF (JUNE) 15,18,16
15    AA=AA*QM
      BB=BB*QM
      CC=CC*QM
      GO TO 17
16    AA=-AA*QP
      BB=BB*QP
      CC=-CC*QP
17    IF (I.NE.IS) RETURN
18    AA=AA-1.
      BB=BB+(AJ*QM+AP*QP)*SDH/SD
      CC=CC+(AJ*QM-AP*QP)*CDH/SD
      RETURN
19    IF (NJUN2.EQ.0) GO TO 23
      QP=PI*BI(I)
      XXI=QP*QP
      XXI=QP*(1.-.5*XXI)/(1.-XXI)
      QP=-(OMC+XXI*SD)/(SD*(AP+XXI*PP)+CD*(XXI*AP-PP))
      IF (JUNE.NE.1) GO TO 20
      AA=-AA*QP
      BB=BB*QP
      CC=-CC*QP
      IF (I.NE.IS) RETURN
20    AA=AA-1.
      D=CD-XXI*SD
      BB=BB+(SDH+AP*QP*(CDH-XXI*SDH))/D
      CC=CC+(CDH+AP*QP*(SDH+XXI*CDH))/D
      RETURN
21    QM=PI*BI(I)
      XXI=QM*QM
      XXI=QM*(1.-.5*XXI)/(1.-XXI)
      QM=(OMC+XXI*SD)/(SD*(AJ-XXI*PM)+CD*(PM+XXI*AJ))
      IF (JUNE.NE.-1) GO TO 22
      AA=AA*QM
      BB=BB*QM
      CC=CC*QM
      IF (I.NE.IS) RETURN
22    AA=AA-1.
      D=CD-XXI*SD
      BB=BB+(AJ*QM*(CDH-XXI*SDH)-SDH)/D
      CC=CC+(CDH-AJ*QM*(SDH+XXI*CDH))/D
      RETURN
23    AA=-1.
      QP=PI*BI(I)
      XXI=QP*QP
      XXI=QP*(1.-.5*XXI)/(1.-XXI)
      CC=1./(CDH-XXI*SDH)
      RETURN
24    WRITE(3,25)  I
      STOP
!
25    FORMAT (43H SBF - SEGMENT CONNECTION ERROR FOR SEGMENT,I5)
      END

!----------------------------------------------------------------------------

      SUBROUTINE SFLDS (T,E)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     SFLDX RETURNS THE FIELD DUE TO GROUND FOR A CURRENT ELEMENT ON
!     THE SOURCE SEGMENT AT T RELATIVE TO THE SEGMENT CENTER.
!
      COMPLEX*16 E,ERV,EZV,ERH,EZH,EPH,T1,EXK,EYK,EZK,EXS,EYS,EZS,EXC
     1,EYC,EZC,XX1,XX2,U,U2,ZRATI,ZRATI2,FRATI,ER,ET,HRV,HZV,HRH
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      COMMON /INCOM/ XO,YO,ZO,SN,XSN,YSN,ISNOR
      COMMON /GWAV/ U,U2,XX1,XX2,R1,R2,ZMH,ZPH
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      DIMENSION E(9)
      DATA PI/3.141592654D+0/,TP/6.283185308D+0/,POT/1.570796327D+0/
      XT=XJ+T*CABJ
      YT=YJ+T*SABJ
      ZT=ZJ+T*SALPJ
      RHX=XO-XT
      RHY=YO-YT
      RHS=RHX*RHX+RHY*RHY
      RHO=SQRT(RHS)
      IF (RHO.GT.0.) GO TO 1
      RHX=1.
      RHY=0.
      PHX=0.
      PHY=1.
      GO TO 2
1     RHX=RHX/RHO
      RHY=RHY/RHO
      PHX=-RHY
      PHY=RHX
2     CPH=RHX*XSN+RHY*YSN
      SPH=RHY*XSN-RHX*YSN
      IF (ABS(CPH).LT.1.D-10) CPH=0.
      IF (ABS(SPH).LT.1.D-10) SPH=0.
      ZPH=ZO+ZT
      ZPHS=ZPH*ZPH
      R2S=RHS+ZPHS
      R2=SQRT(R2S)
      RK=R2*TP
      XX2=DCMPLX(COS(RK),-SIN(RK))
      IF (ISNOR.EQ.1) GO TO 3
!
!     USE NORTON APPROXIMATION FOR FIELD DUE TO GROUND.  CURRENT IS
!     LUMPED AT SEGMENT CENTER WITH CURRENT MOMENT FOR CONSTANT, SINE,
!     OR COSINE DISTRIBUTION.
!
      ZMH=1.
      R1=1.
      XX1=0.
      CALL GWAVE (ERV,EZV,ERH,EZH,EPH)
      ET=-(0.,4.77134)*FRATI*XX2/(R2S*R2)
      ER=2.*ET*DCMPLX(1.D+0,RK)
      ET=ET*DCMPLX(1.D+0-RK*RK,RK)
      HRV=(ER+ET)*RHO*ZPH/R2S
      HZV=(ZPHS*ER-RHS*ET)/R2S
      HRH=(RHS*ER-ZPHS*ET)/R2S
      ERV=ERV-HRV
      EZV=EZV-HZV
      ERH=ERH+HRH
      EZH=EZH+HRV
      EPH=EPH+ET
      ERV=ERV*SALPJ
      EZV=EZV*SALPJ
      ERH=ERH*SN*CPH
      EZH=EZH*SN*CPH
      EPH=EPH*SN*SPH
      ERH=ERV+ERH
      E(1)=(ERH*RHX+EPH*PHX)*S
      E(2)=(ERH*RHY+EPH*PHY)*S
      E(3)=(EZV+EZH)*S
      E(4)=0.
      E(5)=0.
      E(6)=0.
      SFAC=PI*S
      SFAC=SIN(SFAC)/SFAC
      E(7)=E(1)*SFAC
      E(8)=E(2)*SFAC
      E(9)=E(3)*SFAC
      RETURN
!
!     INTERPOLATE IN SOMMERFELD FIELD TABLES
!
3     IF (RHO.LT.1.D-12) GO TO 4
      THET=ATAN(ZPH/RHO)
      GO TO 5
4     THET=POT
5     CALL INTRP (R2,THET,ERV,EZV,ERH,EPH)
!     COMBINE VERTICAL AND HORIZONTAL COMPONENTS AND CONVERT TO X,Y,Z
!     COMPONENTS.  MULTIPLY BY EXP(-JKR)/R.
      XX2=XX2/R2
      SFAC=SN*CPH
      ERH=XX2*(SALPJ*ERV+SFAC*ERH)
      EZH=XX2*(SALPJ*EZV-SFAC*ERV)
      EPH=SN*SPH*XX2*EPH
!     X,Y,Z FIELDS FOR CONSTANT CURRENT
      E(1)=ERH*RHX+EPH*PHX
      E(2)=ERH*RHY+EPH*PHY
      E(3)=EZH
      RK=TP*T
!     X,Y,Z FIELDS FOR SINE CURRENT
      SFAC=SIN(RK)
      E(4)=E(1)*SFAC
      E(5)=E(2)*SFAC
      E(6)=E(3)*SFAC
!     X,Y,Z FIELDS FOR COSINE CURRENT
      SFAC=COS(RK)
      E(7)=E(1)*SFAC
      E(8)=E(2)*SFAC
      E(9)=E(3)*SFAC
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE SOLGF (A,B,C,D,XY,IP,NP,N1,N,MP,M1,M,N1C,N2C,N2CZ)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     SOLVE FOR CURRENT IN N.G.F. PROCEDURE
      COMPLEX*16 A,B,C,D,SUM,XY,Y
      COMMON /SCRATM/ Y(2*MAXSEG)

      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      DIMENSION A(1), B(N1C,1), C(N1C,1), D(N2CZ,1), IP(1), XY(1)
      IFL=14
      IF (ICASX.GT.0) IFL=13
      IF (N2C.GT.0) GO TO 1
!     NORMAL SOLUTION.  NOT N.G.F.
      CALL SOLVES (A,IP,XY,N1C,1,NP,N,MP,M,13,IFL)
      GO TO 22
1     IF (N1.EQ.N.OR.M1.EQ.0) GO TO 5
!     REORDER EXCITATION ARRAY
      N2=N1+1
      JJ=N+1
      NPM=N+2*M1
      DO 2 I=N2,NPM
2     Y(I)=XY(I)
      J=N1
      DO 3 I=JJ,NPM
      J=J+1
3     XY(J)=Y(I)
      DO 4 I=N2,N
      J=J+1
4     XY(J)=Y(I)
5     NEQS=NSCON+2*NPCON
      IF (NEQS.EQ.0) GO TO 7
      NEQ=N1C+N2C
      NEQS=NEQ-NEQS+1
!     COMPUTE INV(A)E1
      DO 6 I=NEQS,NEQ
6     XY(I)=(0.,0.)
7     CALL SOLVES (A,IP,XY,N1C,1,NP,N1,MP,M1,13,IFL)
      NI=0
      NPB=NPBL
!     COMPUTE E2-C(INV(A)E1)
      DO 10 JJ=1,NBBL
      IF (JJ.EQ.NBBL) NPB=NLBL
      IF (ICASX.GT.1) READ (15) ((C(I,J),I=1,N1C),J=1,NPB)
      II=N1C+NI
      DO 9 I=1,NPB
      SUM=(0.,0.)
      DO 8 J=1,N1C
8     SUM=SUM+C(J,I)*XY(J)
      J=II+I
9     XY(J)=XY(J)-SUM
10    NI=NI+NPBL
      IF (ICASX.GT.1) REWIND 15
      JJ=N1C+1
!     COMPUTE INV(D)(E2-C(INV(A)E1)) = I2
      IF (ICASX.GT.1) GO TO 11
      CALL SOLVE (N2C,D,IP(JJ),XY(JJ),N2C)
      GO TO 13
11    IF (ICASX.EQ.4) GO TO 12
      NI=N2C*N2C
      READ (11) (B(J,1),J=1,NI)
      REWIND 11
      CALL SOLVE (N2C,B,IP(JJ),XY(JJ),N2C)
      GO TO 13
12    NBLSYS=NBLSYM
      NPSYS=NPSYM
      NLSYS=NLSYM
      ICASS=ICASE
      NBLSYM=NBBL
      NPSYM=NPBL
      NLSYM=NLBL
      ICASE=3
      REWIND 11
      REWIND 16
      CALL LTSOLV (B,N2C,IP(JJ),XY(JJ),N2C,1,11,16)
      REWIND 11
      REWIND 16
      NBLSYM=NBLSYS
      NPSYM=NPSYS
      NLSYM=NLSYS
      ICASE=ICASS
13    NI=0
      NPB=NPBL
!     COMPUTE INV(A)E1-(INV(A)B)I2 = I1
      DO 16 JJ=1,NBBL
      IF (JJ.EQ.NBBL) NPB=NLBL
      IF (ICASX.GT.1) READ (14) ((B(I,J),I=1,N1C),J=1,NPB)
      II=N1C+NI
      DO 15 I=1,N1C
      SUM=(0.,0.)
      DO 14 J=1,NPB
      JP=II+J
14    SUM=SUM+B(I,J)*XY(JP)
15    XY(I)=XY(I)-SUM
16    NI=NI+NPBL
      IF (ICASX.GT.1) REWIND 14
      IF (N1.EQ.N.OR.M1.EQ.0) GO TO 20
!     REORDER CURRENT ARRAY
      DO 17 I=N2,NPM
17    Y(I)=XY(I)
      JJ=N1C+1
      J=N1
      DO 18 I=JJ,NPM
      J=J+1
18    XY(J)=Y(I)
      DO 19 I=N2,N1C
      J=J+1
19    XY(J)=Y(I)
20    IF (NSCON.EQ.0) GO TO 22
      J=NEQS-1
      DO 21 I=1,NSCON
      J=J+1
      JJ=ISCON(I)
21    XY(JJ)=XY(J)
22    RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE SOLVE (N,A,IP,B,NDIM)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     SUBROUTINE TO SOLVE THE MATRIX EQUATION LU*X=B WHERE L IS A UNIT
!     LOWER TRIANGULAR MATRIX AND U IS AN UPPER TRIANGULAR MATRIX BOTH
!     OF WHICH ARE STORED IN A.  THE RHS VECTOR B IS INPUT AND THE
!     SOLUTION IS RETURNED THROUGH VECTOR B.
!
      COMPLEX*16 A,B,Y,SUM
      INTEGER PI
      COMMON /SCRATM/ Y(2*MAXSEG)
      DIMENSION A(NDIM,NDIM), IP(NDIM), B(NDIM)
!
!     FORWARD SUBSTITUTION
!
      DO 3 I=1,N
      PI=IP(I)
      Y(I)=B(PI)
      B(PI)=B(I)
      IP1=I+1
      IF (IP1.GT.N) GO TO 2
      DO 1 J=IP1,N
      B(J)=B(J)-A(J,I)*Y(I)
1     CONTINUE
2     CONTINUE
3     CONTINUE
!
!     BACKWARD SUBSTITUTION
!
      DO 6 K=1,N
      I=N-K+1
      SUM=(0.,0.)
      IP1=I+1
      IF (IP1.GT.N) GO TO 5
      DO 4 J=IP1,N
      SUM=SUM+A(I,J)*B(J)
4     CONTINUE
5     CONTINUE
      B(I)=(Y(I)-SUM)/A(I,I)
6     CONTINUE
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE SOLVES (A,IP,B,NEQ,NRH,NP,N,MP,M,IFL1,IFL2)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     SUBROUTINE SOLVES, FOR SYMMETRIC STRUCTURES, HANDLES THE
!     TRANSFORMATION OF THE RIGHT HAND SIDE VECTOR AND SOLUTION OF THE
!     MATRIX EQ.
!
      COMPLEX*16 A,B,Y,SUM,SSX
      COMMON /SMAT/ SSX(16,16)
      COMMON /SCRATM/ Y(2*MAXSEG)
      COMMON /MATPAR/ ICASE,NBLOKS,NPBLK,NLAST,NBLSYM,NPSYM,NLSYM,IMAT,I
     1CASX,NBBX,NPBX,NLBX,NBBL,NPBL,NLBL
      DIMENSION A(1), IP(1), B(NEQ,NRH)
      NPEQ=NP+2*MP
      NOP=NEQ/NPEQ
      FNOP=NOP
      FNORM=1./FNOP
      NROW=NEQ
      IF (ICASE.GT.3) NROW=NPEQ
      IF (NOP.EQ.1) GO TO 11
      DO 10 IC=1,NRH
      IF (N.EQ.0.OR.M.EQ.0) GO TO 6
      DO 1 I=1,NEQ
1     Y(I)=B(I,IC)
      KK=2*MP
      IA=NP
      IB=N
      J=NP
      DO 5 K=1,NOP
      IF (K.EQ.1) GO TO 3
      DO 2 I=1,NP
      IA=IA+1
      J=J+1
2     B(J,IC)=Y(IA)
      IF (K.EQ.NOP) GO TO 5
3     DO 4 I=1,KK
      IB=IB+1
      J=J+1
4     B(J,IC)=Y(IB)
5     CONTINUE
!
!     TRANSFORM MATRIX EQ. RHS VECTOR ACCORDING TO SYMMETRY MODES
!
6     DO 10 I=1,NPEQ
      DO 7 K=1,NOP
      IA=I+(K-1)*NPEQ
7     Y(K)=B(IA,IC)
      SUM=Y(1)
      DO 8 K=2,NOP
8     SUM=SUM+Y(K)
      B(I,IC)=SUM*FNORM
      DO 10 K=2,NOP
      IA=I+(K-1)*NPEQ
      SUM=Y(1)
      DO 9 J=2,NOP
9     SUM=SUM+Y(J)*DCONJG(SSX(K,J))
10    B(IA,IC)=SUM*FNORM
11    IF (ICASE.LT.3) GO TO 12
      REWIND IFL1
      REWIND IFL2
!
!     SOLVE EACH MODE EQUATION
!
12    DO 16 KK=1,NOP
      IA=(KK-1)*NPEQ+1
      IB=IA
      IF (ICASE.NE.4) GO TO 13
      I=NPEQ*NPEQ
      READ (IFL1) (A(J),J=1,I)
      IB=1
13    IF (ICASE.EQ.3.OR.ICASE.EQ.5) GO TO 15
      DO 14 IC=1,NRH
14    CALL SOLVE (NPEQ,A(IB),IP(IA),B(IA,IC),NROW)
      GO TO 16
15    CALL LTSOLV (A,NPEQ,IP(IA),B(IA,1),NEQ,NRH,IFL1,IFL2)
16    CONTINUE
      IF (NOP.EQ.1) RETURN
!
!     INVERSE TRANSFORM THE MODE SOLUTIONS
!
      DO 26 IC=1,NRH
      DO 20 I=1,NPEQ
      DO 17 K=1,NOP
      IA=I+(K-1)*NPEQ
17    Y(K)=B(IA,IC)
      SUM=Y(1)
      DO 18 K=2,NOP
18    SUM=SUM+Y(K)
      B(I,IC)=SUM
      DO 20 K=2,NOP
      IA=I+(K-1)*NPEQ
      SUM=Y(1)
      DO 19 J=2,NOP
19    SUM=SUM+Y(J)*SSX(K,J)
20    B(IA,IC)=SUM
      IF (N.EQ.0.OR.M.EQ.0) GO TO 26
      DO 21 I=1,NEQ
21    Y(I)=B(I,IC)
      KK=2*MP
      IA=NP
      IB=N
      J=NP
      DO 25 K=1,NOP
      IF (K.EQ.1) GO TO 23
      DO 22 I=1,NP
      IA=IA+1
      J=J+1
22    B(IA,IC)=Y(J)
      IF (K.EQ.NOP) GO TO 25
23    DO 24 I=1,KK
      IB=IB+1
      J=J+1
24    B(IB,IC)=Y(J)
25    CONTINUE
26    CONTINUE
      RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE TBF (I,ICAP)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     COMPUTE BASIS FUNCTION I
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM

      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      DATA PI/3.141592654D+0/

      JSNO=0
      PP=0.
      JCOX=ICON1(I)
      IF (JCOX.GT.10000) JCOX=I
      JEND=-1
      IEND=-1
      SIG=-1.
      IF (JCOX) 1,10,2
1     JCOX=-JCOX
      GO TO 3
2     SIG=-SIG
      JEND=-JEND
3     JSNO=JSNO+1
      IF (JSNO.GE.JMAX) GO TO 28
      JCO(JSNO)=JCOX
      D=PI*SI(JCOX)
      SDH=SIN(D)
      CDH=COS(D)
      SD=2.*SDH*CDH
      IF (D.GT.0.015) GO TO 4
      OMC=4.*D*D
      OMC=((1.3888889D-3*OMC-4.1666666667D-2)*OMC+.5)*OMC
      GO TO 5
4     OMC=1.-CDH*CDH+SDH*SDH
5     AJ=1./(LOG(1./(PI*BI(JCOX)))-.577215664D+0)
      PP=PP-OMC/SD*AJ
      AX(JSNO)=AJ/SD*SIG
      BX(JSNO)=AJ/(2.*CDH)
      CX(JSNO)=-AJ/(2.*SDH)*SIG
      IF (JCOX.EQ.I) GO TO 8
      IF (JEND.EQ.1) GO TO 6
      JCOX=ICON1(JCOX)
      GO TO 7
6     JCOX=ICON2(JCOX)
7     IF (IABS(JCOX).EQ.I) GO TO 9
      IF (JCOX) 1,28,2
8     BX(JSNO)=-BX(JSNO)
9     IF (IEND.EQ.1) GO TO 11
10    PM=-PP
      PP=0.
      NJUN1=JSNO
      JCOX=ICON2(I)
      IF (JCOX.GT.10000) JCOX=I
      JEND=1
      IEND=1
      SIG=-1.
      IF (JCOX) 1,11,2
11    NJUN2=JSNO-NJUN1
      JSNOP=JSNO+1
      JCO(JSNOP)=I
      D=PI*SI(I)
      SDH=SIN(D)
      CDH=COS(D)
      SD=2.*SDH*CDH
      CD=CDH*CDH-SDH*SDH
      IF (D.GT.0.015) GO TO 12
      OMC=4.*D*D
      OMC=((1.3888889D-3*OMC-4.1666666667D-2)*OMC+.5)*OMC
      GO TO 13
12    OMC=1.-CD
13    AP=1./(LOG(1./(PI*BI(I)))-.577215664D+0)
      AJ=AP
      IF (NJUN1.EQ.0) GO TO 16
      IF (NJUN2.EQ.0) GO TO 20
      QP=SD*(PM*PP+AJ*AP)+CD*(PM*AP-PP*AJ)
      QM=(AP*OMC-PP*SD)/QP
      QP=-(AJ*OMC+PM*SD)/QP
      BX(JSNOP)=(AJ*QM+AP*QP)*SDH/SD
      CX(JSNOP)=(AJ*QM-AP*QP)*CDH/SD
      DO 14 IEND=1,NJUN1
      AX(IEND)=AX(IEND)*QM
      BX(IEND)=BX(IEND)*QM
14    CX(IEND)=CX(IEND)*QM
      JEND=NJUN1+1
      DO 15 IEND=JEND,JSNO
      AX(IEND)=-AX(IEND)*QP
      BX(IEND)=BX(IEND)*QP
15    CX(IEND)=-CX(IEND)*QP
      GO TO 27
16    IF (NJUN2.EQ.0) GO TO 24
      IF (ICAP.NE.0) GO TO 17
      XXI=0.
      GO TO 18
17    QP=PI*BI(I)
      XXI=QP*QP
      XXI=QP*(1.-.5*XXI)/(1.-XXI)
18    QP=-(OMC+XXI*SD)/(SD*(AP+XXI*PP)+CD*(XXI*AP-PP))
      D=CD-XXI*SD
      BX(JSNOP)=(SDH+AP*QP*(CDH-XXI*SDH))/D
      CX(JSNOP)=(CDH+AP*QP*(SDH+XXI*CDH))/D
      DO 19 IEND=1,NJUN2
      AX(IEND)=-AX(IEND)*QP
      BX(IEND)=BX(IEND)*QP
19    CX(IEND)=-CX(IEND)*QP
      GO TO 27
20    IF (ICAP.NE.0) GO TO 21
      XXI=0.
      GO TO 22
21    QM=PI*BI(I)
      XXI=QM*QM
      XXI=QM*(1.-.5*XXI)/(1.-XXI)
22    QM=(OMC+XXI*SD)/(SD*(AJ-XXI*PM)+CD*(PM+XXI*AJ))
      D=CD-XXI*SD
      BX(JSNOP)=(AJ*QM*(CDH-XXI*SDH)-SDH)/D
      CX(JSNOP)=(CDH-AJ*QM*(SDH+XXI*CDH))/D
      DO 23 IEND=1,NJUN1
      AX(IEND)=AX(IEND)*QM
      BX(IEND)=BX(IEND)*QM
23    CX(IEND)=CX(IEND)*QM
      GO TO 27
24    BX(JSNOP)=0.
      IF (ICAP.NE.0) GO TO 25
      XXI=0.
      GO TO 26
25    QP=PI*BI(I)
      XXI=QP*QP
      XXI=QP*(1.-.5*XXI)/(1.-XXI)
26    CX(JSNOP)=1./(CDH-XXI*SDH)
27    JSNO=JSNOP
      AX(JSNO)=-1.
      RETURN
28    WRITE(3,29)  I
      STOP
!
29    FORMAT (43H TBF - SEGMENT CONNECTION ERROR FOR SEGMENT,I5)
      END

!----------------------------------------------------------------------------

      SUBROUTINE TEST (F1R,F2R,TR,F1I,F2I,TI,DMIN)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     TEST FOR CONVERGENCE IN NUMERICAL INTEGRATION
!
      DEN=ABS(F2R)
      TR=ABS(F2I)
      IF (DEN.LT.TR) DEN=TR
      IF (DEN.LT.DMIN) DEN=DMIN
      IF (DEN.LT.1.D-37) GO TO 1
      TR=ABS((F1R-F2R)/DEN)
      TI=ABS((F1I-F2I)/DEN)
      RETURN

1     TR=0.
      TI=0.
      RETURN
      END

!----------------------------------------------------------------------------

      SUBROUTINE TRIO (J)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     COMPUTE THE COMPONENTS OF ALL BASIS FUNCTIONS ON SEGMENT J
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM

      COMMON /SEGJ/ AX(jmax),BX(jmax),CX(jmax),JCO(jmax),	! av14
     -JSNO,ISCON(50),NSCON,IPCON(10),NPCON			! av14

      JSNO=0
      JCOX=ICON1(J)
      IF (JCOX.GT.10000) GO TO 7
      JEND=-1
      IEND=-1
      IF (JCOX) 1,7,2
1     JCOX=-JCOX
      GO TO 3
2     JEND=-JEND
3     IF (JCOX.EQ.J) GO TO 6
      JSNO=JSNO+1
      IF (JSNO.GE.JMAX) GO TO 9
      CALL SBF (JCOX,J,AX(JSNO),BX(JSNO),CX(JSNO))
      JCO(JSNO)=JCOX
      IF (JEND.EQ.1) GO TO 4
      JCOX=ICON1(JCOX)
      GO TO 5
4     JCOX=ICON2(JCOX)
5     IF (JCOX) 1,9,2
6     IF (IEND.EQ.1) GO TO 8
7     JCOX=ICON2(J)
      IF (JCOX.GT.10000) GO TO 8
      JEND=1
      IEND=1
      IF (JCOX) 1,8,2
8     JSNO=JSNO+1
      CALL SBF (J,J,AX(JSNO),BX(JSNO),CX(JSNO))
      JCO(JSNO)=J
      RETURN
9     WRITE(3,10)  J
      STOP
!
10    FORMAT (44H TRIO - SEGMENT CONNENTION ERROR FOR SEGMENT,I5)
      END
!----------------------------------------------------------------------------

      SUBROUTINE UNERE (XOB,YOB,ZOB)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!     CALCULATES THE ELECTRIC FIELD DUE TO UNIT CURRENT IN THE T1 AND T2
!     DIRECTIONS ON A PATCH
      COMPLEX*16 EXK,EYK,EZK,EXS,EYS,EZS,EXC,EYC,EZC,ZRATI,ZRATI2,T1
     1,ER,Q1,Q2,RRV,RRH,EDP,FRATI
      COMMON /DATAJ/ S,B,XJ,YJ,ZJ,CABJ,SABJ,SALPJ,EXK,EYK,EZK,EXS,EYS,
     &EZS,EXC,EYC,EZC,RKH,IND1,INDD1,IND2,INDD2,IEXK,IPGND
      COMMON /GND/ZRATI,ZRATI2,FRATI,T1,T2,CL,CH,SCRWL,SCRWR,NRADL,
     &KSYMP,IFAR,IPERF
      EQUIVALENCE (T1XJ,CABJ), (T1YJ,SABJ), (T1ZJ,SALPJ), (T2XJ,B), (T2Y
     1J,IND1), (T2ZJ,IND2)
      DATA TPI,CONST/6.283185308D+0,4.771341188D+0/
!     CONST=ETA/(8.*PI**2)
      ZR=ZJ
      T1ZR=T1ZJ
      T2ZR=T2ZJ
      IF (IPGND.NE.2) GO TO 1
      ZR=-ZR
      T1ZR=-T1ZR
      T2ZR=-T2ZR
1     RX=XOB-XJ
      RY=YOB-YJ
      RZ=ZOB-ZR
      R2=RX*RX+RY*RY+RZ*RZ
      IF (R2.GT.1.D-20) GO TO 2
      EXK=(0.,0.)
      EYK=(0.,0.)
      EZK=(0.,0.)
      EXS=(0.,0.)
      EYS=(0.,0.)
      EZS=(0.,0.)
      RETURN
2     R=SQRT(R2)
      TT1=-TPI*R
      TT2=TT1*TT1
      RT=R2*R
      ER=DCMPLX(SIN(TT1),-COS(TT1))*(CONST*S)
      Q1=DCMPLX(TT2-1.,TT1)*ER/RT
      Q2=DCMPLX(3.-TT2,-3.*TT1)*ER/(RT*R2)
      ER=Q2*(T1XJ*RX+T1YJ*RY+T1ZR*RZ)
      EXK=Q1*T1XJ+ER*RX
      EYK=Q1*T1YJ+ER*RY
      EZK=Q1*T1ZR+ER*RZ
      ER=Q2*(T2XJ*RX+T2YJ*RY+T2ZR*RZ)
      EXS=Q1*T2XJ+ER*RX
      EYS=Q1*T2YJ+ER*RY
      EZS=Q1*T2ZR+ER*RZ
      IF (IPGND.EQ.1) GO TO 6
      IF (IPERF.NE.1) GO TO 3
      EXK=-EXK
      EYK=-EYK
      EZK=-EZK
      EXS=-EXS
      EYS=-EYS
      EZS=-EZS
      GO TO 6
3     XYMAG=SQRT(RX*RX+RY*RY)
      IF (XYMAG.GT.1.D-6) GO TO 4
      PX=0.
      PY=0.
      CTH=1.
      RRV=(1.,0.)
      GO TO 5
4     PX=-RY/XYMAG
      PY=RX/XYMAG
      CTH=RZ/SQRT(XYMAG*XYMAG+RZ*RZ)
      RRV=SQRT(1.-ZRATI*ZRATI*(1.-CTH*CTH))
5     RRH=ZRATI*CTH
      RRH=(RRH-RRV)/(RRH+RRV)
      RRV=ZRATI*RRV
      RRV=-(CTH-RRV)/(CTH+RRV)
      EDP=(EXK*PX+EYK*PY)*(RRH-RRV)
      EXK=EXK*RRV+EDP*PX
      EYK=EYK*RRV+EDP*PY
      EZK=EZK*RRV
      EDP=(EXS*PX+EYS*PY)*(RRH-RRV)
      EXS=EXS*RRV+EDP*PX
      EYS=EYS*RRV+EDP*PY
      EZS=EZS*RRV
6     RETURN
      END
!----------------------------------------------------------------------------

      SUBROUTINE WIRE (XW1,YW1,ZW1,XW2,YW2,ZW2,RAD,RDEL,RRAD,NS,ITG)
! ***
!     DOUBLE PRECISION 6/4/85
!
      INCLUDE 'nec2dpar.inc'
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     SUBROUTINE WIRE GENERATES SEGMENT GEOMETRY DATA FOR A STRAIGHT
!     WIRE OF NS SEGMENTS.
!
      COMMON /DATA/ X(MAXSEG),Y(MAXSEG),Z(MAXSEG),SI(MAXSEG),BI(MAXSEG),
     &ALP(MAXSEG),BET(MAXSEG),WLAM,ICON1(2*MAXSEG),ICON2(2*MAXSEG),
     &ITAG(2*MAXSEG),ICONX(MAXSEG),LD,N1,N2,N,NP,M1,M2,M,MP,IPSYM
      DIMENSION X2(1), Y2(1), Z2(1)
      EQUIVALENCE (X2(1),SI(1)), (Y2(1),ALP(1)), (Z2(1),BET(1))
      IST=N+1
      N=N+NS
      NP=N
      MP=M
      IPSYM=0
      IF (NS.LT.1) RETURN
      XD=XW2-XW1
      YD=YW2-YW1
      ZD=ZW2-ZW1
      IF (ABS(RDEL-1.).LT.1.D-6) GO TO 1
      DELZ=SQRT(XD*XD+YD*YD+ZD*ZD)
      XD=XD/DELZ
      YD=YD/DELZ
      ZD=ZD/DELZ
      DELZ=DELZ*(1.-RDEL)/(1.-RDEL**NS)
      RD=RDEL
      GO TO 2
1     FNS=NS
      XD=XD/FNS
      YD=YD/FNS
      ZD=ZD/FNS
      DELZ=1.
      RD=1.
2     RADZ=RAD
      XS1=XW1
      YS1=YW1
      ZS1=ZW1
      DO 3 I=IST,N
      ITAG(I)=ITG
      XS2=XS1+XD*DELZ
      YS2=YS1+YD*DELZ
      ZS2=ZS1+ZD*DELZ
      X(I)=XS1
      Y(I)=YS1
      Z(I)=ZS1
      X2(I)=XS2
      Y2(I)=YS2
      Z2(I)=ZS2
      BI(I)=RADZ
      DELZ=DELZ*RD
      RADZ=RADZ*RRAD
      XS1=XS2
      YS1=YS2
3     ZS1=ZS2
      X2(N)=XW2
      Y2(N)=YW2
      Z2(N)=ZW2
      RETURN
      END
      COMPLEX*16 FUNCTION ZINT(SIGL,ROLAM)
! ***
!     DOUBLE PRECISION 6/4/85
!
      IMPLICIT REAL*8(A-H,O-Z)
! ***
!
!     ZINT COMPUTES THE INTERNAL IMPEDANCE OF A CIRCULAR WIRE
!
!
      COMPLEX*16 TH,PH,F,G,FJ,CN,BR1,BR2
      COMPLEX*16 CC1,CC2,CC3,CC4,CC5,CC6,CC7,CC8,CC9,CC10,CC11,CC12
     1,CC13,CC14
      DIMENSION FJX(2), CNX(2), CCN(28)
      EQUIVALENCE (FJ,FJX), (CN,CNX), (CC1,CCN(1)), (CC2,CCN(3)), (CC3,C
     1CN(5)), (CC4,CCN(7)), (CC5,CCN(9)), (CC6,CCN(11)), (CC7,CCN(13)),
     2(CC8,CCN(15)), (CC9,CCN(17)), (CC10,CCN(19)), (CC11,CCN(21)), (CC1
     32,CCN(23)), (CC13,CCN(25)), (CC14,CCN(27))
      DATA PI,POT,TP,TPCMU/3.1415926D+0,1.5707963D+0,6.2831853D+0,
     12.368705D+3/
      DATA CMOTP/60.00/,FJX/0.,1./,CNX/.70710678D+0,.70710678D+0/
      DATA CCN/6.D-7,1.9D-6,-3.4D-6,5.1D-6,-2.52D-5,0.,-9.06D-5,-9.01D-5
     1,0.,-9.765D-4,.0110486D+0,-.0110485D+0,0.,-.3926991D+0,1.6D-6,
     2-3.2D-6,1.17D-5,-2.4D-6,3.46D-5,3.38D-5,5.D-7,2.452D-4,-1.3813D-3
     3,1.3811D-3,-6.25001D-2,-1.D-7,.7071068D+0,.7071068D+0/
      TH(D)=(((((CC1*D+CC2)*D+CC3)*D+CC4)*D+CC5)*D+CC6)*D+CC7
      PH(D)=(((((CC8*D+CC9)*D+CC10)*D+CC11)*D+CC12)*D+CC13)*D+CC14
      F(D)=SQRT(POT/D)*EXP(-CN*D+TH(-8./X))
      G(D)=EXP(CN*D+TH(8./X))/SQRT(TP*D)
      X=SQRT(TPCMU*SIGL)*ROLAM
      IF (X.GT.110.) GO TO 2
      IF (X.GT.8.) GO TO 1
      Y=X/8.
      Y=Y*Y
      S=Y*Y
      BER=((((((-9.01D-6*S+1.22552D-3)*S-.08349609D+0)*S+2.6419140D+0)
     1*S-32.363456D+0)*S+113.77778D+0)*S-64.)*S+1.
      BEI=((((((1.1346D-4*S-.01103667D+0)*S+.52185615D+0)*S-
     110.567658D+0)*S+72.817777D+0)*S-113.77778D+0)*S+16.)*Y
      BR1=DCMPLX(BER,BEI)
      BER=(((((((-3.94D-6*S+4.5957D-4)*S-.02609253D+0)*S+.66047849D+0)
     1*S-6.0681481D+0)*S+14.222222D+0)*S-4.)*Y)*X
      BEI=((((((4.609D-5*S-3.79386D-3)*S+.14677204D+0)*S-2.3116751D+0)
     1*S+11.377778D+0)*S-10.666667D+0)*S+.5)*X
      BR2=DCMPLX(BER,BEI)
      BR1=BR1/BR2
      GO TO 3
1     BR2=FJ*F(X)/PI
      BR1=G(X)+BR2
      BR2=G(X)*PH(8./X)-BR2*PH(-8./X)
      BR1=BR1/BR2
      GO TO 3
2     BR1=DCMPLX(.70710678D+0,-.70710678D+0)
3     ZINT=FJ*SQRT(CMOTP/SIGL)*BR1/ROLAM
      RETURN
      END

