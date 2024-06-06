@Echo Off
chcp 65001 > NUL
SetLocal DisableDelayedExpansion

::-----НАСТРОЙКИ-----::
:: Расширения (через пробел)
Set Extensions=v64 bin
:: Уровень сжатия (1 - fastest, 9 - ultra)
Set CompressionLevel=5
:: Удалять исходный файл, после архивации (0 - нет, 1 - да)
Set RemoveFile=1
::-------------------::

:: 7zip файлы
Set SevenZip=7za.exe 7za.dll 7zxa.dll
:: Устанавливаем корневую папку
Set DataRoot=%~dp0
:: Проверка наличия 7zip
set flag=0
For %%Z In (%SevenZip%) Do (
	if not exist %%Z (
		echo  Не найден %%Z
		set flag=1
	)
)
if %flag%==1 (
	goto end
)

:: Подтверждение удаления исходных файлов
if %RemoveFile%==1 (
	echo ВНИМАНИЕ! Включено удаление исходных файлов.
	set /p ans="Введите "Y" для продолжения: "
) else (
	goto continue
)	
if not %ans%==Y (
	goto end
)

:continue
del log.txt
:: Файлы корневой папки
Echo  Каталог "\":
For %%A In (%Extensions%) Do (
	For /F "delims=" %%B In ('Dir "%DataRoot%\*.%%A" /B /A-D 2^>nul') Do (
		@REM Echo		%DataRoot%%%B
		7za.exe a -tzip -sccUTF-8 -bso0 -bse0 -bsp0 -mx%CompressionLevel% "%DataRoot%%%~nB.zip" "%DataRoot%%%B1"
		if %ERRORLEVEL%==0 (
			echo 		OK %DataRoot%%%B&echo OK %DataRoot%%%B >> log.txt
			if %RemoveFile%==1 del "%DataRoot%%%B"
		) else (
			echo 		ERROR %DataRoot%%%B&echo ERROR %DataRoot%%%B >> log.txt
		)
	)
)
Echo.
:: Получаем структуру вложенных папок
For /F "delims=" %%A In ('Dir "%DataRoot%\" /S /B /AD') Do (
	Set RelativePath=%%A
:: Получение относительного пути из полного
	SetLocal EnableDelayedExpansion
	Set RelativePath=!RelativePath:%DataRoot%=!
:: Файлы из вложенных папок
	Echo  Каталог "\!RelativePath!\":
	endLocal
	For %%B In (%Extensions%) Do (
		For /F "delims=" %%C In ('Dir "%%~A\*.%%B" /B /A-D 2^>nul') Do (
			@REM Echo		%%~A\%%C
			7za.exe a -tzip -sccUTF-8 -bso0 -bse0 -bsp0 -mx%CompressionLevel% "%%~A\%%~nC.zip" "%%~A\%%C"
			if %ERRORLEVEL%==0 (
				echo 		OK %%~A\%%C&echo OK %%~A\%%C >> log.txt
				if %RemoveFile%==1 del "%%~A\%%C"
			) else (
				echo 		ERROR %%~A\%%C&echo ERROR %%~A\%%C >> log.txt
			)
		)
	)
	Echo.
)
:end
Echo  Выполнено.
Pause