## Microsoft Function Naming Convention: http://msdn.microsoft.com/en-us/library/ms714428(v=vs.85).aspx

#region Function Get-WindowsReleaseHistory
Function Get-WindowsReleaseHistory
    {
        <#
          .SYNOPSIS
          Retrieves the Windows release history by scraping the release information from the internet.
          
          .DESCRIPTION
          This function dynamically navigates the HTML document returned from each web request using XPath, and the HTMLAgilityPack library. All prerequisite requirements are handled within the function.
                    
          .EXAMPLE
          Get-WindowsReleaseHistory
          
          .EXAMPLE
          Get-WindowsReleaseHistory -Verbose

          .EXAMPLE
          Get-WindowsReleaseHistory | Where-Object {($_.Type -ieq 'Client') -and ($_.HasLongTermServicingBuild -eq $True)}

          .EXAMPLE
          Get-WindowsReleaseHistory | Where-Object {($_.Type -ieq 'Server')}

          .EXAMPLE
          Get-WindowsReleaseHistory | Where-Object {($_.Releases.KBArticle -ieq 'KB5044384')}

          .NOTES
          OperatingSystem           : Windows 11
          Type                      : Client
          ReleaseID                 : 24H2
          InitialReleaseVersion     : 10.0.26100.1742
          HasLongTermServicingBuild : True
          Releases                  : {@{ServicingOptions=System.String[]; AvailabilityDate=10/24/2024 12:00:00 AM; Version=10.0.26100.2161; KBArticle=KB5044384; 
                                      KBArticleURL=https://support.microsoft.com/help/5044384}, @{ServicingOptions=System.String[]; AvailabilityDate=10/8/2024 12:00:00 AM; Version=10.0.26100.2033; 
                                      KBArticle=KB5044284; KBArticleURL=https://support.microsoft.com/help/5044284}, @{ServicingOptions=System.String[]; AvailabilityDate=10/1/2024 12:00:00 AM; 
                                      Version=10.0.26100.1742; KBArticle=; KBArticleURL=https://support.microsoft.com/help/5044284}}
        #>
        
        [CmdletBinding()]  
          Param
            (                                                      
                [Parameter(Mandatory=$False)]
                [Switch]$ContinueOnError        
            )
                    
        Begin
          {
              [ScriptBlock]$ErrorHandlingDefinition = {
                                                          $ErrorMessageList = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                                                            $ErrorMessageList.Add('Message', $_.Exception.Message)
                                                            $ErrorMessageList.Add('Category', $_.Exception.ErrorRecord.FullyQualifiedErrorID)
                                                            $ErrorMessageList.Add('Script', $_.InvocationInfo.ScriptName)
                                                            $ErrorMessageList.Add('LineNumber', $_.InvocationInfo.ScriptLineNumber)
                                                            $ErrorMessageList.Add('LinePosition', $_.InvocationInfo.OffsetInLine)
                                                            $ErrorMessageList.Add('Code', $_.InvocationInfo.Line.Trim())

                                                          ForEach ($ErrorMessage In $ErrorMessageList.GetEnumerator())
                                                            {
                                                                $LoggingDetails.ErrorMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) -  ERROR: $($ErrorMessage.Key): $($ErrorMessage.Value)"
                                                                Write-Warning -Message ($LoggingDetails.ErrorMessage)
                                                            }

                                                          Switch (($ContinueOnError.IsPresent -eq $False) -or ($ContinueOnError -eq $False))
                                                            {
                                                                {($_ -eq $True)}
                                                                  {                  
                                                                      Throw
                                                                  }
                                                            }
                                                      }
                                                        
              Try
                {
                    $DateTimeLogFormat = 'dddd, MMMM dd, yyyy @ hh:mm:ss.FFF tt'  ###Monday, January 01, 2019 @ 10:15:34.000 AM###
                    [ScriptBlock]$GetCurrentDateTimeLogFormat = {(Get-Date).ToString($DateTimeLogFormat)}
                    $DateTimeMessageFormat = 'MM/dd/yyyy HH:mm:ss.FFF'  ###03/23/2022 11:12:48.347###
                    [ScriptBlock]$GetCurrentDateTimeMessageFormat = {(Get-Date).ToString($DateTimeMessageFormat)}
                    $DateFileFormat = 'yyyyMMdd'  ###20190403###
                    [ScriptBlock]$GetCurrentDateFileFormat = {(Get-Date).ToString($DateFileFormat)}
                    $DateTimeFileFormat = 'yyyyMMdd_HHmmss'  ###20190403_115354###
                    [ScriptBlock]$GetCurrentDateTimeFileFormat = {(Get-Date).ToString($DateTimeFileFormat)}
                    $TextInfo = (Get-Culture).TextInfo
                    $LoggingDetails = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'    
                      $LoggingDetails.LogMessage = $Null
                      $LoggingDetails.WarningMessage = $Null
                      $LoggingDetails.ErrorMessage = $Null
                    $CommonParameterList = New-Object -TypeName 'System.Collections.Generic.List[String]'
                      $CommonParameterList.AddRange([System.Management.Automation.PSCmdlet]::CommonParameters)
                      $CommonParameterList.AddRange([System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
                    $DateTimeProperties = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                      $DateTimeProperties.FormatList = New-Object -TypeName 'System.Collections.Generic.List[String]'
                        $DateTimeProperties.FormatList.AddRange(([System.Globalization.DateTimeFormatInfo]::CurrentInfo.GetAllDateTimePatterns()))
                        $DateTimeProperties.FormatList.AddRange(([System.Globalization.DateTimeFormatInfo]::InvariantInfo.GetAllDateTimePatterns()))
                        $DateTimeProperties.FormatList.Add('yyyyMM')
                        $DateTimeProperties.FormatList.Add('yyyyMMdd')
                      $DateTimeProperties.Culture = $Null
                      $DateTimeProperties.Styles = New-Object -TypeName 'System.Collections.Generic.List[System.Globalization.DateTimeStyles]'
                        $DateTimeProperties.Styles.Add([System.Globalization.DateTimeStyles]::AssumeLocal)
                        $DateTimeProperties.Styles.Add([System.Globalization.DateTimeStyles]::AllowWhiteSpaces)
                    $RegexOptionList = New-Object -TypeName 'System.Collections.Generic.List[System.Text.RegularExpressions.RegexOptions]'
                      $RegexOptionList.Add('IgnoreCase')
                      $RegexOptionList.Add('Multiline')
                    $XPathExpressionDictionary = New-Object -TypeName 'System.Collections.Generic.Dictionary[[System.String], [System.Xml.XPath.XPathExpression]]'
                      $XPathExpressionDictionary.ServicingChannelNodes = [System.Xml.XPath.XPathExpression]::Compile("descendant::table[not(contains(@id,'historyTable_'))]")
                      $XPathExpressionDictionary.HistoryTableNodes = [System.Xml.XPath.XPathExpression]::Compile("descendant::table[contains(@id,'historyTable_')]")
                      $XPathExpressionDictionary.OperatingSystemInfoNode = [System.Xml.XPath.XPathExpression]::Compile("preceding::strong[position()=1]")
                      $XPathExpressionDictionary.TableRowHeaderDefinitionNode = [System.Xml.XPath.XPathExpression]::Compile("descendant::tr[position()=1]")
                      $XPathExpressionDictionary.TableRowHeaderNodes = [System.Xml.XPath.XPathExpression]::Compile("descendant::th")
                      $XPathExpressionDictionary.TableRowDataNodes = [System.Xml.XPath.XPathExpression]::Compile("descendant::tr[position()>1]")
                      $XPathExpressionDictionary.TableRowDataValueNodes = [System.Xml.XPath.XPathExpression]::Compile("descendant::td")
                              
                    #Determine the date and time we executed the function
                      $FunctionStartTime = (Get-Date)
                    
                    [String]$FunctionName = $MyInvocation.MyCommand
                    [System.IO.FileInfo]$FunctionPath = $PSCommandPath
                    [System.IO.DirectoryInfo]$FunctionDirectory = "$($FunctionPath.Directory.FullName)"
                      
                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Function `'$($FunctionName)`' is beginning. Please Wait..."
                    Write-Verbose -Message ($LoggingDetails.LogMessage)
              
                    #Define Default Action Preferences
                      $ErrorActionPreference = 'Stop'
                      
                    [String[]]$AvailableScriptParameters = (Get-Command -Name ($FunctionName)).Parameters.GetEnumerator() | Where-Object {($_.Value.Name -inotin $CommonParameterList)} | ForEach-Object {"-$($_.Value.Name):$($_.Value.ParameterType.Name)"}
                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Available Function Parameter(s) = $($AvailableScriptParameters -Join ', ')"
                    Write-Verbose -Message ($LoggingDetails.LogMessage)

                    [String[]]$SuppliedScriptParameters = $PSBoundParameters.GetEnumerator() | ForEach-Object {"-$($_.Key):$($_.Value.GetType().Name)"}
                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Supplied Function Parameter(s) = $($SuppliedScriptParameters -Join ', ')"
                    Write-Verbose -Message ($LoggingDetails.LogMessage)

                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Execution of $($FunctionName) began on $($FunctionStartTime.ToString($DateTimeLogFormat))"
                    Write-Verbose -Message ($LoggingDetails.LogMessage)

                    #region Adjust security protocol type(s)
                      [System.Net.SecurityProtocolType]$DesiredSecurityProtocol = [System.Net.SecurityProtocolType]::TLS12
  
                      $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Attempting to set the desired security protocol to `"$($DesiredSecurityProtocol.ToString().ToUpper())`". Please Wait..."
                      Write-Verbose -Message ($LoggingDetails.LogMessage)
          
                      $Null = [System.Net.ServicePointManager]::SecurityProtocol = ($DesiredSecurityProtocol)
                    #endregion

                    #region Load any required libraries
                      $PackageDictionary = New-Object -TypeName 'System.Collections.Generic.Dictionary[[System.String], [System.Object]]'
                        $PackageDictionary.GetSources = {Get-PackageSource -Force -ErrorAction SilentlyContinue}
                        $PackageDictionary.RequiredSources = New-Object -TypeName 'System.Collections.Generic.Dictionary[[System.String], [System.Collections.Hashtable]]'
                          $PackageDictionary.RequiredSources.NuGetPackages = @{Location = 'https://www.nuget.org/api/v2'; ProviderName = 'NuGet'; Trusted = $True}
                        $PackageDictionary.GetPackages = {Get-Package -Scope AllUsers}
                        $PackageDictionary.RequiredPackages = New-Object -TypeName 'System.Collections.Generic.Dictionary[[System.String], [System.Collections.Hashtable]]'
                          $PackageDictionary.RequiredPackages.HtmlAgilityPack = @{DotNetVersion = 'Net45'; ProviderName = $PackageDictionary.RequiredSources.NuGetPackages.ProviderName}

                      ForEach ($PackageDictionaryKVP In $PackageDictionary.GetEnumerator())
                        {
                            Switch ($PackageDictionaryKVP.Key)
                              {
                                  {($_ -iin @('RequiredSources'))}
                                    {
                                        $PackageSources = $PackageDictionary.GetSources.Invoke()
                  
                                        ForEach ($RequiredSourceKVP In $PackageDictionary.RequiredSources.GetEnumerator())
                                          {
                                              Switch ($PackageSources.Name -inotcontains $RequiredSourceKVP.Key)
                                                {
                                                    {($_ -eq $True)}
                                                      {
                                                          $Null = Register-PackageSource -Name ($RequiredSourceKVP.Key) -Location ($RequiredSourceKVP.Value.Location) -ProviderName ($RequiredSourceKVP.Value.ProviderName) -Trusted:$($RequiredSourceKVP.Value.Trusted) -Force -Confirm:$False
                                                      }
                                                }
                                          }
                                    }

                                  {($_ -iin @('RequiredPackages'))}
                                    {
                                        $Packages = $PackageDictionary.GetPackages.Invoke()
                  
                                        ForEach ($RequiredPackageKVP In $PackageDictionary.RequiredPackages.GetEnumerator())
                                          {
                                              $PackageInfoLocal = Try {Get-Package -Name ($RequiredPackageKVP.Key) -ProviderName ($RequiredPackageKVP.Value.ProviderName)} Catch {$Null}
                        
                                              Switch ($Null -ieq $PackageInfoLocal)
                                                {
                                                    {($_ -eq $True)}
                                                      {
                                                          $PackageInfoRemote = Find-Package -Name ($RequiredPackageKVP.Key) -ProviderName ($RequiredPackageKVP.Value.ProviderName) -Force | Select-Object -First 1

                                                          Switch ($Null -ine $PackageInfoRemote)
                                                            {
                                                                {($_ -eq $True)}
                                                                  {                                    
                                                                      $PackageInfoRemote = Install-Package -Name ($RequiredPackageKVP.Key) -ProviderName ($RequiredPackageKVP.Value.ProviderName) -SkipDependencies -Force -Confirm:$False

                                                                      $PackageInfoLocal = Try {Get-Package -Name ($RequiredPackageKVP.Key) -ProviderName ($RequiredPackageKVP.Value.ProviderName)} Catch {$Null}
                                                                  }
                                                            }
                                                      }
                                                }

                                              [System.IO.FileInfo]$PackageSource = $PackageInfoLocal.Source

                                              [System.IO.FileInfo]$PackageLibraryPath = "$($PackageSource.Directory.FullName)\lib\$($RequiredPackageKVP.Value.DotNetVersion)\$($RequiredPackageKVP.Key).dll"

                                              $Null = [System.Reflection.Assembly]::LoadFrom($PackageLibraryPath.FullName)
                                          }
                                    }
                              }
                        }
                      #endregion
                                                              
                    #Create an object that will contain the functions output.
                      $OutputObjectList = New-Object -TypeName 'System.Collections.Generic.List[PSObject]'
                }
              Catch
                {
                    $ErrorHandlingDefinition.Invoke()
                }
              Finally
                {
                    
                }
          }

        Process
          {           
              Try
                {  
                    #Instantiate an instance of the WebClient .NET class
                      $WebClient = New-Object -TypeName 'System.Net.WebClient'
                          
                    #Define the update history URL list                              
                      [String]$URLListSourceURL = "https://raw.githubusercontent.com/Grace-Solutions/WindowsReleaseHistory/refs/heads/main/URLList.txt"
                          
                    #Process the update history URL list
                      $URLList = Try {$WebClient.DownloadString($URLListSourceURL).Split("`r`n", [System.StringSplitOptions]::RemoveEmptyEntries)} Catch {$Null}

                      $URLListCount = ($URLList | Measure-Object).Count

                      Switch ($URLListCount -gt 0)
                        {
                            {($_ -eq $True)}
                              {
                                  For ($URLListIndex = 0; $URLListIndex -lt $URLListCount; $URLListIndex++)
                                    {
                                        Try
                                          {
                                              [System.URI]$URL = $ExecutionContext.InvokeCommand.ExpandString(($URLList[$URLListIndex]))

                                              $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Attempting to retrieve data from `"$($URL.OriginalString)`". Please Wait..."
                                              Write-Verbose -Message ($LoggingDetails.LogMessage)

                                              $HTMLWebRequest = New-Object -TypeName 'HtmlAgilityPack.HtmlWeb'

                                              $HTMLWebRequestObject = $HTMLWebRequest.Load($URL.OriginalString)

                                              Switch ($URL.OriginalString)
                                                {
                                                    {($_ -imatch '(^.*Server.*$)')}
                                                      {
                                                          $RegularExpressionTable.OSName = New-Object -TypeName 'System.Text.RegularExpressions.Regex' -ArgumentList @('(Windows\s+Server\s+\d+)', $RegexOptionList)
                                                          $RegularExpressionTable.OSInfo = New-Object -TypeName 'System.Text.RegularExpressions.Regex' -ArgumentList @('(?<OSName>.+\s+.+\s+\d{4,})(?:\s+)?(?:.+)(?<BuildNumber>\d{5,})(?:.+)?', $RegexOptionList)
                                                      }

                                                    Default
                                                      {
                                                          $RegularExpressionTable.OSName = New-Object -TypeName 'System.Text.RegularExpressions.Regex' -ArgumentList @('(Windows\s+\d+)', $RegexOptionList)
                                                          $RegularExpressionTable.OSInfo = New-Object -TypeName 'System.Text.RegularExpressions.Regex' -ArgumentList @('(?:.+)?(?:Version)(?:\s+)?(?<ReleaseID>[a-z0-9]{4,})(?:\s+)?(?:.+)(?<BuildNumber>\d{5,})(?:.+)?', $RegexOptionList)
                                                      }
                                                }

                                              $HTMLDocumentObject = $HTMLWebRequestObject.DocumentNode
                                                    
                                              $ServicingChannelNodes = $HTMLDocumentObject.SelectNodes($XPathExpressionDictionary.ServicingChannelNodes.Expression)

                                              $ServicingChannelNodeCount = ($ServicingChannelNodes | Measure-Object).Count

                                              $ServicingChannelObjectList = New-Object -TypeName 'System.Collections.Generic.List[System.Management.Automation.PSObject]'

                                              For ($ServicingChannelNodeIndex = 0; $ServicingChannelNodeIndex -lt $ServicingChannelNodeCount; $ServicingChannelNodeIndex++)
                                                {
                                                    $ServicingChannelNode = $ServicingChannelNodes[$ServicingChannelNodeIndex]

                                                    $TableRowHeaderDefinitionNode = $ServicingChannelNode.SelectSingleNode($XPathExpressionDictionary.TableRowHeaderDefinitionNode.Expression)

                                                    Switch ($Null -ine $TableRowHeaderDefinitionNode)
                                                      {
                                                          {($_ -eq $True)}
                                                            {
                                                                $TableRowHeaderNodes = $TableRowHeaderDefinitionNode.SelectNodes($XPathExpressionDictionary.TableRowHeaderNodes.Expression)

                                                                Switch ($Null -ine $TableRowHeaderNodes)
                                                                  {
                                                                      {($_ -eq $True)}
                                                                        {
                                                                            $TableRowDataNodes = $ServicingChannelNode.SelectNodes($XPathExpressionDictionary.TableRowDataNodes.Expression)

                                                                            $TableRowDataNodeCount = ($TableRowDataNodes | Measure-Object).Count

                                                                            For ($TableRowDataNodeIndex = 0; $TableRowDataNodeIndex -lt $TableRowDataNodeCount; $TableRowDataNodeIndex++)
                                                                              {
                                                                                  $TableRowDataNode = $TableRowDataNodes[$TableRowDataNodeIndex]

                                                                                  $ServicingChannelObjectProperties = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                                                                                    $ServicingChannelObjectProperties.OperatingSystem = $Null
                                                                                    $ServicingChannelObjectProperties.ReleaseID = $Null

	                                                                                $TableRowDataValueNodes = $TableRowDataNode.SelectNodes($XPathExpressionDictionary.TableRowDataValueNodes)

	                                                                                $TableRowDataValueNodeCount = ($TableRowDataValueNodes | Measure-Object).Count

	                                                                                For ($TableRowDataValueNodeIndex = 0; $TableRowDataValueNodeIndex -lt $TableRowDataValueNodeCount; $TableRowDataValueNodeIndex++)
		                                                                                {
                                                                                        $TableRowHeaderNode =  $TableRowHeaderNodes[$TableRowDataValueNodeIndex]

                                                                                        $OriginalTableRowHeaderName = Try {$TableRowHeaderNode.InnerText} Catch {$Null}

                                                                                        Try
                                                                                          {                                                                                                                            
                                                                                              $TableRowHeaderName = $TextInfo.ToTitleCase($OriginalTableRowHeaderName) -ireplace '(\s+)', ''

                                                                                              $TableRowDataValueNode = $TableRowDataValueNodes[$TableRowDataValueNodeIndex]

                                                                                              $TableRowDataValue = Try {$TableRowDataValueNode.InnerText} Catch {$Null}

                                                                                              Switch (([String]::IsNullOrEmpty($TableRowDataValue) -eq $False) -and ([String]::IsNullOrWhiteSpace($TableRowDataValue) -eq $False))
                                                                                                {
                                                                                                    {($_ -eq $True)}
                                                                                                      {
                                                                                                          Switch ($TableRowHeaderName)
                                                                                                            {
                                                                                                                {($_ -imatch '(^.*Date$)')}
                                                                                                                  {
                                                                                                                      $DateTime = New-Object -TypeName 'DateTime'

                                                                                                                      $DateTimeProperties.Input = $TableRowDataValue
                                                                                                                      $DateTimeProperties.Successful = [DateTime]::TryParseExact($DateTimeProperties.Input, $DateTimeProperties.FormatList, $DateTimeProperties.Culture, $DateTimeProperties.Styles.ToArray(), [Ref]$DateTime)
                                                                                                                      $DateTimeProperties.DateTime = $DateTime

                                                                                                                      $DateTimeObject = New-Object -TypeName 'PSObject' -Property ($DateTimeProperties)
                                                                                            
                                                                                                                      Switch ($DateTimeObject.Successful)
                                                                                                                        {
                                                                                                                            {($_ -eq $True)}
                                                                                                                              {
                                                                                                                                  $ServicingChannelObjectProperties."$($TableRowHeaderName)" = $DateTimeObject.DateTime.Date
                                                                                                                              }

                                                                                                                            Default
                                                                                                                              {
                                                                                                                                  $ServicingChannelObjectProperties."$($TableRowHeaderName)" = $TextInfo.ToTitleCase($DateTimeProperties.Input)
                                                                                                                              }
                                                                                                                        }
                                                                                                                  }

                                                                                                                {($_ -imatch '(^.*Release$)|(^Version$)')}
                                                                                                                  {
                                                                                                                      $ServicingChannelObjectProperties.OperatingSystem = $TableRowDataValue

                                                                                                                      Switch ($TableRowDataValue -imatch '(^.*\(Version.*\)$)')
                                                                                                                        {
                                                                                                                            {($_ -eq $True)}
                                                                                                                              {
                                                                                                                                  $ServicingChannelObjectProperties.ReleaseID = Try {[Regex]::Match($TableRowDataValue, '(?:.+\(version\s+)(.+)(?:\))').Groups['1'].Value} Catch {$Null}
                                                                                                                              }

                                                                                                                            Default
                                                                                                                              {
                                                                                                                                  $ServicingChannelObjectProperties.ReleaseID = Try {[Regex]::Match($TableRowDataValue, '[a-z0-9]{4,4}').Value} Catch {$Null}
                                                                                                                              }
                                                                                                                        }
                                                                                                                  }
                                                                                                                                                                        
                                                                                                                {($_ -imatch '(^.*Build$)')}
                                                                                                                  {                                                                                
                                                                                                                      Try
                                                                                                                        {
                                                                                                                            $TableRowDataValue = New-Object -TypeName 'System.Version' -ArgumentList @(10, 0, ($TableRowDataValue.Split('.')[0]), ($TableRowDataValue.Split('.')[1]))
                                                                                                                        }
                                                                                                                      Catch
                                                                                                                        {
                                                                                                                            $TableRowDataValue = New-Object -TypeName 'System.Version' -ArgumentList @(10, 0, ($TableRowDataValue.Split('.')[0]), 0)
                                                                                                                        }
                                                                                                                                                                      
                                                                                                                      $TableRowHeaderName = 'Version'
                                                                                                                                                                      
                                                                                                                      $ServicingChannelObjectProperties."$($TableRowHeaderName)" = $TableRowDataValue
                                                                                                                  }

                                                                                                                {($_ -imatch '(^.*Servicing.*Option.*$)')}
                                                                                                                  {                                                                                  
                                                                                                                      $ServicingChannelObjectProperties."$($TableRowHeaderName)s" = $TableRowDataValue
                                                                                                                  }

                                                                                                                {($_ -imatch '(^Editions$)')}
                                                                                                                  {                                                                                  
                                                                                                                      $ServicingChannelObjectProperties."$($TableRowHeaderName)" = $TableRowDataValueNode.InnerText.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries).Trim()
                                                                                                                  }

                                                                                                                Default
                                                                                                                  {
                                                                                                                      $ServicingChannelObjectProperties."$($TableRowHeaderName)" = $TableRowDataValue
                                                                                                                  }
                                                                                                            }
                                                                                                      }

                                                                                                    Default
                                                                                                      {
                                                                                                          $ServicingChannelObjectProperties."$($TableRowHeaderName)" = $Null
                                                                                                      }
                                                                                                }
                                                                                          }
                                                                                        Catch
                                                                                          {
                                                                                              $ServicingChannelObjectProperties."$($TableRowHeaderName)" = $Null
                                                                                          }
                                                                                        Finally
                                                                                          {                                                                                                                            

                                                                                          }
		                                                                                }

                                                                                  $ServicingChannelObject = New-Object -TypeName 'System.Management.Automation.PSObject' -Property ($ServicingChannelObjectProperties)

                                                                                  $ServicingChannelObjectList.Add($ServicingChannelObject)
                                                                              }
                                                                        }
                                                                  }
                                                            }
                                                      }
                                                }

                                              $HistoryTableNodes = $HTMLDocumentObject.SelectNodes($XPathExpressionDictionary.HistoryTableNodes.Expression)

                                              $HistoryTableNodeCount = ($HistoryTableNodes | Measure-Object).Count

                                              For ($HistoryTableNodeIndex = 0; $HistoryTableNodeIndex -lt $HistoryTableNodeCount; $HistoryTableNodeIndex++)
                                                {
                                                    $HistoryTableNode = $HistoryTableNodes[$HistoryTableNodeIndex]

                                                    $OperatingSystemInfoNode = $HistoryTableNode.SelectSingleNode($XPathExpressionDictionary.OperatingSystemInfoNode.Expression)

                                                    Switch ($Null -ine $OperatingSystemInfoNode)
                                                      {
                                                          {($_ -eq $True)}
                                                            {
                                                                $BuildNumber = Try {$RegularExpressionTable.OSInfo.Match($OperatingSystemInfoNode.GetDirectInnerText()).Groups['BuildNumber'].Value} Catch {$Null}
                                                                      
                                                                $OutputObjectProperties = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                                                                  $OutputObjectProperties.OperatingSystem = Try {$RegularExpressionTable.OSName.Match($HTMLDocumentObject.OuterHtml).Value} Catch {$Null}
                                                                  $OutputObjectProperties.Type = 'Client'
                                                                  $OutputObjectProperties.ReleaseID = Try {$RegularExpressionTable.OSInfo.Match($OperatingSystemInfoNode.GetDirectInnerText()).Groups['ReleaseID'].Value} Catch {$Null}
                                                                  $OutputObjectProperties.InitialReleaseVersion = New-Object -TypeName 'System.Version'
                                                                  $OutputObjectProperties.HasLongTermServicingBuild = $False
                                                                  $OutputObjectProperties.Releases = New-Object -TypeName 'System.Collections.Generic.List[System.Management.Automation.PSObject]'

                                                                Switch ($URL.OriginalString)
                                                                  {
                                                                      {($_ -imatch '(^.*Server.*$)')}
                                                                        {
                                                                            $OutputObjectProperties.OperatingSystem = Try {$RegularExpressionTable.OSName.Match($OperatingSystemInfoNode.GetDirectInnerText()).Value} Catch {$Null}
                                                                            $OutputObjectProperties.ReleaseID = Try {[System.Text.RegularExpressions.Regex]::Match($OutputObjectProperties.OperatingSystem, '\d{4,4}').Value} Catch {$Null}  
                                                                            $OutputObjectProperties.Type = "Server"
                                                                        }
                                                                  }

                                                                Switch ($OutputObjectProperties.OperatingSystem)
                                                                  {
                                                                      {($_ -imatch '(^SomeOtherOperatingSystemName$)')}
                                                                        {
                                                                            #$OutputObjectProperties.InitialReleaseVersion = New-Object -TypeName 'System.Version' -ArgumentList @(10, 0, $BuildNumber)
                                                                        }

                                                                      Default
                                                                        {
                                                                            $OutputObjectProperties.InitialReleaseVersion = New-Object -TypeName 'System.Version' -ArgumentList @(10, 0, $BuildNumber, 0)
                                                                        }
                                                                  }

                                                                $OutputObjectProperties.HasLongTermServicingBuild = Try {[Boolean]($ServicingChannelObjectList | Where-Object {($_.Version.Build -eq $OutputObjectProperties.InitialReleaseVersion.Build) -and ($_.ServicingOptions -imatch '(^LTSB|LTSC|.*Long.*Term.*$)')})} Catch {$False}
                                                                      
                                                                $TableRowHeaderDefinitionNode = $HistoryTableNode.SelectSingleNode($XPathExpressionDictionary.TableRowHeaderDefinitionNode.Expression)

                                                                Switch ($Null -ine $TableRowHeaderDefinitionNode)
                                                                  {
                                                                      {($_ -eq $True)}
                                                                        {
                                                                            $TableRowHeaderNodes = $TableRowHeaderDefinitionNode.SelectNodes($XPathExpressionDictionary.TableRowHeaderNodes.Expression)

                                                                            Switch ($Null -ine $TableRowHeaderNodes)
                                                                              {
                                                                                  {($_ -eq $True)}
                                                                                    {
                                                                                        $HistoryTableObjectProperties = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                                                                                              
                                                                                        $TableRowDataNodes = $HistoryTableNode.SelectNodes($XPathExpressionDictionary.TableRowDataNodes.Expression)

                                                                                        $TableRowDataNodeCount = ($TableRowDataNodes | Measure-Object).Count

                                                                                        For ($TableRowDataNodeIndex = 0; $TableRowDataNodeIndex -lt $TableRowDataNodeCount; $TableRowDataNodeIndex++)
                                                                                          {
	                                                                                            $TableRowDataNode = $TableRowDataNodes[$TableRowDataNodeIndex]

	                                                                                            $TableRowDataValueNodes = $TableRowDataNode.SelectNodes($XPathExpressionDictionary.TableRowDataValueNodes)

	                                                                                            $TableRowDataValueNodeCount = ($TableRowDataValueNodes | Measure-Object).Count

	                                                                                            For ($TableRowDataValueNodeIndex = 0; $TableRowDataValueNodeIndex -lt $TableRowDataValueNodeCount; $TableRowDataValueNodeIndex++)
		                                                                                            {
                                                                                                    $TableRowHeaderNode =  $TableRowHeaderNodes[$TableRowDataValueNodeIndex]

                                                                                                    $OriginalTableRowHeaderName = Try {$TableRowHeaderNode.GetDirectInnerText()} Catch {$TableRowHeaderNode.InnerText}

                                                                                                    Switch (([String]::IsNullOrEmpty($OriginalTableRowHeaderName) -eq $False) -and ([String]::IsNullOrWhiteSpace($OriginalTableRowHeaderName) -eq $False))
                                                                                                      {
                                                                                                          {($_ -eq $True)}
                                                                                                            {
                                                                                                                Try
                                                                                                                  {                                                                                                                            
                                                                                                                      $TableRowHeaderName = $TextInfo.ToTitleCase($OriginalTableRowHeaderName) -ireplace '(\s+)', ''

                                                                                                                      $TableRowDataValueNode = $TableRowDataValueNodes[$TableRowDataValueNodeIndex]

                                                                                                                      $TableRowDataValue = Try {$TableRowDataValueNode.InnerText} Catch {$Null}

                                                                                                                      Switch (([String]::IsNullOrEmpty($TableRowDataValue) -eq $False) -and ([String]::IsNullOrWhiteSpace($TableRowDataValue) -eq $False))
                                                                                                                        {
                                                                                                                            {($_ -eq $True)}
                                                                                                                              {
                                                                                                                                  Switch ($TableRowHeaderName)
                                                                                                                                    {
                                                                                                                                        {($_ -imatch '(^AvailabilityDate$)')}
                                                                                                                                          {
                                                                                                                                              $DateTime = New-Object -TypeName 'DateTime'

                                                                                                                                              $DateTimeProperties.Input = Try {$TableRowDataValueNode.InnerText} Catch {$Null}
                                                                                                                                              $DateTimeProperties.Successful = [DateTime]::TryParseExact($DateTimeProperties.Input, $DateTimeProperties.FormatList, $DateTimeProperties.Culture, $DateTimeProperties.Styles.ToArray(), [Ref]$DateTime)
                                                                                                                                              $DateTimeProperties.DateTime = $DateTime

                                                                                                                                              $DateTimeObject = New-Object -TypeName 'PSObject' -Property ($DateTimeProperties)
                                                                                            
                                                                                                                                              Switch ($DateTimeObject.Successful)
                                                                                                                                                {
                                                                                                                                                    {($_ -eq $True)}
                                                                                                                                                      {
                                                                                                                                                          $HistoryTableObjectProperties."$($TableRowHeaderName)" = $DateTimeObject.DateTime.Date
                                                                                                                                                      }

                                                                                                                                                    Default
                                                                                                                                                      {
                                                                                                                                                          $HistoryTableObjectProperties."$($TableRowHeaderName)" = $DateTimeObject.DateTime.Date
                                                                                                                                                      }
                                                                                                                                                }
                                                                                                                                          }
                                                                                                                                                                        
                                                                                                                                        {($_ -imatch '(^Build|OSBuild$)')}
                                                                                                                                          {                                                                                
                                                                                                                                              Try
                                                                                                                                                {
                                                                                                                                                    $TableRowDataValue = New-Object -TypeName 'System.Version' -ArgumentList @($OutputObjectProperties.InitialReleaseVersion.Major, $OutputObjectProperties.InitialReleaseVersion.Minor, $OutputObjectProperties.InitialReleaseVersion.Build, ($TableRowDataValue.Split('.')[1]))
                                                                                                                                                }
                                                                                                                                              Catch
                                                                                                                                                {
                                                                                                                                                    $TableRowDataValue = New-Object -TypeName 'System.Version' -ArgumentList @($OutputObjectProperties.InitialReleaseVersion.Major, $OutputObjectProperties.InitialReleaseVersion.Minor, $OutputObjectProperties.InitialReleaseVersion.Build, $OutputObjectProperties.InitialReleaseVersion.Revision)
                                                                                                                                                }
                                                                                                                                                                      
                                                                                                                                              $TableRowHeaderName = 'Version'
                                                                                                                                                                      
                                                                                                                                              $HistoryTableObjectProperties."$($TableRowHeaderName)" = $TableRowDataValue
                                                                                                                                          }

                                                                                                                                        {($_ -imatch '(^KBArticle$)')}
                                                                                                                                          {                                                                                                                                                                                                                                                
                                                                                                                                              $HistoryTableObjectProperties."$($TableRowHeaderName)" = $TableRowDataValue

                                                                                                                                              $HistoryTableObjectProperties."$($TableRowHeaderName)URL" = Try {New-Object -TypeName 'System.URI' -ArgumentList ($TableRowDataValueNode.SelectSingleNode('descendant::a[1]').Attributes['href'].Value)} Catch {$Null}
                                                                                                                                          }

                                                                                                                                        {($_ -imatch '(^.*Servicing.*Option.*$)')}
                                                                                                                                          {                                                                                  
                                                                                                                                              $TableRowDataValueList = New-Object -TypeName 'System.Collections.Generic.List[System.String]'

                                                                                                                                              $TableRowDataValueString = Try {$TableRowDataValueNode.InnerText -ireplace '[^a-z0-9\s]', '' -ireplace '\s{2,}', ','} Catch {$Null}

                                                                                                                                              Switch (([String]::IsNullOrEmpty($TableRowDataValueString) -eq $False) -and ([String]::IsNullOrWhiteSpace($TableRowDataValueString) -eq $False))
                                                                                                                                                {
                                                                                                                                                    {($_ -eq $True)}
                                                                                                                                                      {
                                                                                                                                                          $TableRowDataValueListEntries = $TableRowDataValueString.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries)

                                                                                                                                                          $TableRowDataValueListEntryCount = ($TableRowDataValueListEntries | Measure-Object).Count

                                                                                                                                                          For ($TableRowDataValueListEntryIndex = 0; $TableRowDataValueListEntryIndex -lt $TableRowDataValueListEntryCount; $TableRowDataValueListEntryIndex++)
                                                                                                                                                            {
                                                                                                                                                                $TableRowDataValueListEntry = $TableRowDataValueListEntries[$TableRowDataValueListEntryIndex]

                                                                                                                                                                Switch (([String]::IsNullOrEmpty($TableRowDataValueListEntry) -eq $False) -and ([String]::IsNullOrWhiteSpace($TableRowDataValueListEntry) -eq $False))
                                                                                                                                                                  {
                                                                                                                                                                      {($_ -eq $True)}
                                                                                                                                                                        {
                                                                                                                                                                            $TableRowDataValueList.Insert($TableRowDataValueListEntryIndex, $TableRowDataValueListEntry)
                                                                                                                                                                        }
                                                                                                                                                                  }
                                                                                                                                                            }
                                                                                                                                                      }
                                                                                                                                                }

                                                                                                                                              $HistoryTableObjectProperties."$($TableRowHeaderName)s" = $TableRowDataValueList.ToArray()
                                                                                                                                          }

                                                                                                                                        Default
                                                                                                                                          {
                                                                                                                                              $HistoryTableObjectProperties."$($TableRowHeaderName)" = $TableRowDataValue
                                                                                                                                          }
                                                                                                                                    }
                                                                                                                              }

                                                                                                                            Default
                                                                                                                              {
                                                                                                                                  $HistoryTableObjectProperties."$($TableRowHeaderName)" = $Null
                                                                                                                              }
                                                                                                                        }
                                                                                                                  }
                                                                                                                Catch
                                                                                                                  {
                                                                                                                      $HistoryTableObjectProperties."$($TableRowHeaderName)" = $Null
                                                                                                                  }
                                                                                                                Finally
                                                                                                                  {                                                                                                                            

                                                                                                                  }
                                                                                                            }
                                                                                                      }
		                                                                                            }

                                                                                              Switch ($HistoryTableObjectProperties.Keys.Count -gt 0)
                                                                                                {
                                                                                                    {($_ -eq $True)}
                                                                                                      {
                                                                                                          $HistoryTableObject = New-Object -TypeName 'PSObject' -Property ($HistoryTableObjectProperties)
                                                                                                                                        
                                                                                                          Switch ($OutputObjectProperties.Releases.Contains($HistoryTableObject))
                                                                                                            {
                                                                                                                {($_ -eq $False)}
                                                                                                                  {
                                                                                                                      $OutputObjectProperties.Releases.Add($HistoryTableObject)
                                                                                                                  }
                                                                                                            }
                                                                                                      }
                                                                                                }
                                                                                          }
                                                                                    }
                                                                              }
                                                                        }
                                                                  }

                                                                $InitialReleaseVersion = $OutputObjectProperties.Releases.Version | Sort-Object -Descending | Select-Object -Last 1

                                                                Switch ($Null -ine $InitialReleaseVersion)
                                                                  {
                                                                      {($_ -eq $True)}
                                                                        {
                                                                            $OutputObjectProperties.InitialReleaseVersion = $InitialReleaseVersion
                                                                        }
                                                                  }

                                                                $OutputObjectProperties.Releases = $OutputObjectProperties.Releases.ToArray()

                                                                $OutputObject = New-Object -TypeName 'System.Management.Automation.PSObject' -Property ($OutputObjectProperties)

                                                                $OutputObjectList.Add($OutputObject)
                                                            }
                                                      }
                                                }
                                          }
                                        Catch
                                          {
                                              $ErrorHandlingDefinition.Invoke()
                                          }
                                        Finally
                                          {
                                                  
                                          }
                                    }
                              }
                        }
                }
              Catch
                {
                    $ErrorHandlingDefinition.Invoke()
                }
              Finally
                {
                    
                }
          }
        
        End
          {                                        
              Try
                {
                    #Determine the date and time the function completed execution
                      $FunctionEndTime = (Get-Date)

                      $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Execution of $($FunctionName) ended on $($FunctionEndTime.ToString($DateTimeLogFormat))"
                      Write-Verbose -Message ($LoggingDetails.LogMessage)

                    #Log the total script execution time  
                      $FunctionExecutionTimespan = New-TimeSpan -Start ($FunctionStartTime) -End ($FunctionEndTime)

                      $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Function execution took $($FunctionExecutionTimespan.Hours.ToString()) hour(s), $($FunctionExecutionTimespan.Minutes.ToString()) minute(s), $($FunctionExecutionTimespan.Seconds.ToString()) second(s), and $($FunctionExecutionTimespan.Milliseconds.ToString()) millisecond(s)"
                      Write-Verbose -Message ($LoggingDetails.LogMessage)
                    
                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Function `'$($FunctionName)`' is completed."
                    Write-Verbose -Message ($LoggingDetails.LogMessage)
                }
              Catch
                {
                    $ErrorHandlingDefinition.Invoke()
                }
              Finally
                {
                    Write-Output -InputObject ($OutputObjectList.ToArray())
                }
          }
    }
#endregion

<#
  Get-WindowsReleaseHistory -Verbose
#>
