@echo off
echo.

REM
REM This .bat file programs Watchman firmware onto the MCU (SAMG55) 
REM or radio (nRF52), using a Segger J-Link.
REM
REM It requires:
REM . J-Link Serial Number
REM . Firmware binary filename
REM
REM example:
REM
REM   C:\> flash_mcu.bat 59304899 watchman_v3_reference_design_jtag.bin
REM

SET SEGGER_PATH=c:\Program Files (x86)\SEGGER\JLink_V616b

rem settings for the MCU jlink
SET MCU_SN=%1
SET MCU_FILENAME=%2
SET MCU_DEVICE=ATSAMG55J19
SET MCU_INTERFACE=SWD
SET MCU_SPEED=25000
SET MCU_ERASE_CMDFILE=mcu_erase.jlink
SET MCU_FLASH_CMDFILE=mcu_flash.jlink
SET MCU_VERIFY_CMDFILE=mcu_verify.jlink

echo tools path: %SEGGER_PATH%

rem J-Link serial number is required
IF [%MCU_SN%] EQU [] (
    echo error, no jlink serial number provided
    echo flash_mcu.bat ^<j-link serial-number^> ^<binary^>
    exit /b -2
)

rem Path to MCU binary is required
IF [%MCU_FILENAME%] EQU [] (
    echo error, no path to MCU binary provided
    echo flash_mcu.bat ^<j-link serial-number^> ^<binary^>
    exit /b -3
)

rem we are creating the cmdfile dyamically so delete the old one
IF exist %MCU_FLASH_CMDFILE% (
    echo found stale cmdfile "%MCU_FLASH_CMDFILE%", deleting
    del /f %MCU_FLASH_CMDFILE%
)
IF exist %MCU_VERIFY_CMDFILE% (
    echo found stale cmdfile "%MCU_VERIFY_CMDFILE%", deleting
    del /f %MCU_VERIFY_CMDFILE%
)

rem build the flash cmdfile
echo generating flash cmdfile
echo h >> %MCU_FLASH_CMDFILE%
echo loadfile %MCU_FILENAME% >> %MCU_FLASH_CMDFILE%
echo h >> %MCU_FLASH_CMDFILE%
echo q >> %MCU_FLASH_CMDFILE%

rem build the verify cmdfile
echo generating verify cmdfile
echo h >> %MCU_VERIFY_CMDFILE%
echo verify %MCU_FILENAME% >> %MCU_VERIFY_CMDFILE%
echo h >> %MCU_VERIFY_CMDFILE%
echo q >> %MCU_VERIFY_CMDFILE%

echo connecting to device SN=%MCU_SN%, flashing image %MCU_FILENAME%...

rem these need to be done as two separate steps, otherwise they don't always complete successfully

echo erasing
"%SEGGER_PATH%\JLink.exe" ^
-selectemubysn %MCU_SN% ^
-device %MCU_DEVICE% ^
-if %MCU_INTERFACE% ^
-speed %MCU_SPEED% ^
-commandfile %MCU_ERASE_CMDFILE%

echo flashing
"%SEGGER_PATH%\JLink.exe" ^
-selectemubysn %MCU_SN% ^
-device %MCU_DEVICE% ^
-if %MCU_INTERFACE% ^
-speed %MCU_SPEED% ^
-commandfile %MCU_FLASH_CMDFILE%

echo verifying
"%SEGGER_PATH%\JLink.exe" ^
-selectemubysn %MCU_SN% ^
-device %MCU_DEVICE% ^
-if %MCU_INTERFACE% ^
-speed %MCU_SPEED% ^
-commandfile %MCU_VERIFY_CMDFILE%

echo flash complete
echo.

