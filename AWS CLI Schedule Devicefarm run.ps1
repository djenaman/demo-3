$awsProjectARN = 'arn:aws:devicefarm:us-west-2:409629073475:project:cdf9a723-8fe3-433e-90f2-e02cb9686ee5'
$awsDevicePoolARN ='arn:aws:devicefarm:us-west-2:409629073475:devicepool:cdf9a723-8fe3-433e-90f2-e02cb9686ee5/1c366a73-ff92-4b0d-8d40-63260023d3b9'
$awsTestSpecARN8=''
$awsTestRunName='testAWSCLI run 001'
$awsTestType="APPIUM_JAVA_TESTNG"
${bamboo.build.working.directory} = 'C:\Users\dipak.kumar\bamboo-home\xml-data\build-dir\PROJ-PN-PJ\'
$testPackagePath22 = join-path ${bamboo.build.working.directory} '\prudentialAutomation\target\prudentialAutomationArchive.zip'
Write-Host "Script is uploading the APK file to AWS.... " -ForegroundColor red -BackgroundColor white
$awsCreateAPKUploadJSONResponse = aws devicefarm create-upload --project-arn $awsProjectARN --name prutopia_test_v9.apk --type ANDROID_APP
$APKUploadObj = ConvertFrom-Json -InputObject "$awsCreateAPKUploadJSONResponse"
$awsAPKUploadSignURL = $APKUploadObj.upload.url
$awsAPKARN = $APKUploadObj.upload.arn
Remove-Item alias:curl
Remove-Item alias:curl
curl -T 'D:\Prudential Docs\Prudential App\prutopia_test_v9.apk' "$awsAPKUploadSignURL"
Write-Host "Waiting for the APK upload status to be success.... " -ForegroundColor red -BackgroundColor white

Write-Host "Script is uploading the maven application zip file to AWS.... " -ForegroundColor red -BackgroundColor white
$awsCreateTestPackageUploadJSONResponse = aws devicefarm create-upload --project-arn $awsProjectARN --name prudentialAutomationArchive.zip --type APPIUM_JAVA_TESTNG_TEST_PACKAGE
$TestPackageUploadObj = ConvertFrom-Json -InputObject "$awsCreateTestPackageUploadJSONResponse"
$awsTestPackageUploadSignURL = $TestPackageUploadObj.upload.url
$awsTestPackageARN = $TestPackageUploadObj.upload.arn
curl -T 'D:\Bitbucket\prucea-qaautomation\prudentialAutomation\target\prudentialAutomationArchive.zip' "$awsTestPackageUploadSignURL"
Write-Host "Script is scheduling the run with above uploaded files and configuration.... " -ForegroundColor red -BackgroundColor white
$awsScheduleRunJSONResponse = aws devicefarm schedule-run --project-arn "$awsProjectARN" --app-arn "$awsAPKARN" --device-pool-arn "$awsDevicePoolARN" --name "$awsTestRunName" --test type="$awsTestType",testPackageArn="$awsTestPackageARN"
$awsSchedulrRunObject = ConvertFrom-Json -InputObject "$awsScheduleRunJSONResponse"
$awsScheduleRunARN = $awsSchedulrRunObject.run.arn
$waitCount = 0
while($true){
$awsRunStatusJSONResponse = aws devicefarm get-run -–arn "$awsScheduleRunARN"
$awsRunStatusObject = ConvertFrom-Json -InputObject $awsRunStatusJSONResponse
if($awsRunStatusObject.run.status -eq 'COMPLETED')
{
break
}
if("$waitCount" -gt 300)
{
Write-Host "Script run did not stop after 30 minutes....closing the execution " -ForegroundColor red -BackgroundColor white
Throw "Script execution hang...."
}
Start-Sleep -Milliseconds 6000
$waitCount++
}