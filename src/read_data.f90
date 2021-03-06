PROGRAM read_data

  IMPLICIT NONE
  CHARACTER(200) :: buffer, filename, dirname
  INTEGER :: arg_count
  INTEGER :: error
  INTEGER :: i,j
  INTEGER :: month, year
  LOGICAL :: isthere, iscreated

  TYPE :: ECdata
    CHARACTER(200) :: buffer
    INTEGER :: year, month, day, hour, minute
    CHARACTER(200) :: Ux, Uy, Uz, Ts, co2, h2o, ind
    REAL :: second
    CHARACTER(200) :: diag
    CHARACTER(200) :: h2o_hmp, T_hmp
  END TYPE ECdata

  TYPE :: input
    INTEGER :: fid
    CHARACTER(200) :: filename
  END TYPE input

  INTEGER :: daytemp = 0

  TYPE(ECdata) :: record

  TYPE(input) :: files(10)

  arg_count = command_argument_count()

  IF (arg_count < 2) THEN
    WRITE(*,*) "Error! Please read README file!"
    GOTO 1000
  END IF


  CALL get_command_argument(1, buffer)    ! Read year and month from command line

  READ(buffer(1:4),*) year
  READ(buffer(6:7),*) month

  WRITE(dirname,"('Data/',I4.4,'-',I2.2,'/.')") year, month
  INQUIRE(FILE=TRIM(dirname),EXIST=isthere)
  IF (isthere) THEN
    CONTINUE
  ELSE
    WRITE(*,"('\n  Please create directory ',A,' ...\n')") TRIM(ADJUSTL(dirname))
    STOP
  END IF

  WRITE(filename,"('Data/',I4.4,'-',I2.2,'/',I4.4,'-',I2.2,'.dat')") year, month, year, month

  DO i = 1, arg_count - 1        ! Read input file names from command line
    files(i)%fid = i*100
    CALL get_command_argument(i+1,files(i)%filename)
  END DO

  ! Open output file and write file headers

  OPEN(UNIT=50,FILE=filename,ACTION='write',IOSTAT=error)
  IF (error/=0) GOTO 1000

  WRITE(50,"(A)") """TOA5"",""CZO_EC1"",""CR1000"",""4745"",""CR1000.Std.16"",""CPU:CZO_EC_d2.cr1"",""61052"",""ts_data"""
  WRITE(50,"(A)") """TIMESTAMP"",""RECORD"",""Ux"",""Uy"",""Uz"",""Ts"",""co2"",""h2o"",""diag"",""h2o_hmp"",""T_hmp"""
  WRITE(50,"(A)") """TS"",""RN"",""m/s"",""m/s"",""m/s"",""C"",""mg/(m^3)"",""g/(m^3)"",""unitless"",""g/(m^3)"",""C"""
  WRITE(50,"(A)") """"","""",""Smp"",""Smp"",""Smp"",""Smp"",""Smp"",""Smp"",""Smp"",""Smp"",""Smp"""


  WRITE(*,*)"\n  Start reading in file ... \n"
  
  DO i = 1, arg_count - 1
    OPEN(UNIT=files(i)%fid,FILE=TRIM(ADJUSTL(files(i)%filename)),ACTION='read',IOSTAT=error)
    IF (error/=0) goto 1000

    WRITE(*,"('\n  Reading ',A,'...\n')") TRIM(ADJUSTL(files(i)%filename))

    READ(files(i)%fid,*) buffer
    READ(files(i)%fid,*) buffer
    READ(files(i)%fid,*) buffer
    READ(files(i)%fid,*) buffer

    DO WHILE(.TRUE.)
      READ(files(i)%fid,*,IOSTAT = error) record%buffer, record%ind, record%Ux, record%Uy, record%Uz, record%Ts, record%co2, record%h2o, record%diag, record%h2o_hmp, record%T_hmp
      IF (error < 0 ) THEN
      EXIT
      ELSE IF (error > 0) THEN
        CYCLE
      END IF

      READ(record%buffer(:4),*) record%year
      READ(record%buffer(6:7),*) record%month
      READ(record%buffer(9:10),*) record%day
      READ(record%buffer(12:13),*) record%hour
      READ(record%buffer(15:16),*) record%minute
      READ(record%buffer(18:),*) record%second

      IF (record%year > year) EXIT

      IF (record%year < year) CYCLE

      IF (record%month < month) CYCLE

      IF (record%month > month) EXIT

      IF (record%day /= daytemp) THEN
        WRITE(*,"('\n  Now copying ',I2.2,'-',I2.2,' data...')") record%month,record%day
        daytemp = record%day
      END IF

      IF (record%month == month) THEN
        CALL write_to_file(50,record)
      END IF
    END DO
    CLOSE(files(i)%fid)
  END DO

  WRITE(*,*)"\n  done.\n"

1000 CONTINUE

END

SUBROUTINE write_to_file(fid, record)

  IMPLICIT NONE
  INTEGER :: fid
  TYPE :: ECdata
    CHARACTER(200) :: buffer
    INTEGER :: year, month, day, hour, minute
    CHARACTER(200) :: Ux, Uy, Uz, Ts, co2, h2o, ind
    REAL :: second
    CHARACTER(200) :: diag
    CHARACTER(200) :: h2o_hmp, T_hmp
  END TYPE ECdata

  TYPE(ECdata) :: record

  WRITE(fid,"(A)") """"//trim(adjustl(record%buffer))//""""//","//trim(adjustl(record%ind))//","//trim(adjustl(record%Ux))//","//trim(adjustl(record%Uy))//","//&
    trim(adjustl(record%Uz))//","//trim(adjustl(record%Ts))//","//trim(adjustl(record%co2))//","//trim(adjustl(record%h2o))//","//&
    trim(adjustl(record%diag))//","//trim(adjustl(record%h2o_hmp))//","//trim(adjustl(record%T_hmp))

END SUBROUTINE write_to_file
