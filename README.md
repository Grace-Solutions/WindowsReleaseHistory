# Get-WindowsReleaseHistory

## SYNOPSIS
Retrieves the Windows release history by scraping the release information from the internet.

## SYNTAX

```
Get-WindowsReleaseHistory [-ContinueOnError] [<CommonParameters>]
```

## DESCRIPTION
This function dynamically navigates the HTML document returned from each web request using XPath, and the HTMLAgilityPack library.
All prerequisite requirements are handled within the function.

## EXAMPLES

### EXAMPLE 1
```
Get-WindowsReleaseHistory
```

### EXAMPLE 2
```
Get-WindowsReleaseHistory -Verbose
```

### EXAMPLE 3
```
Get-WindowsReleaseHistory | Where-Object {($_.Type -ieq 'Client') -and ($_.HasLongTermServicingBuild -eq $True)}
```

### EXAMPLE 4
```
Get-WindowsReleaseHistory | Where-Object {($_.Type -ieq 'Server')}
```

### EXAMPLE 5
```
Get-WindowsReleaseHistory | Where-Object {($_.Releases.KBArticle -ieq 'KB5044384')}
```

## PARAMETERS

### -ContinueOnError
{{ Fill ContinueOnError Description }}

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Each operating system will look similar to the following structure

Type   | HasLongTermServicingBuild | ReleaseID | InitialReleaseVersion | OperatingSystem    
------ | ------------------------- | --------- | --------------------- | -------------------
Client | False                     | 1703      | 10.0.15063.138        | Windows 10         
Server | True                      | 2022      | 10.0.20348.202        | Windows Server 2022
Client | False                     | 22H2      | 10.0.22621.521        | Windows 11         
Client | False                     | 21H1      | 10.0.19043.985        | Windows 10         
Client | True                      | 1607      | 10.0.14393.10         | Windows 10         


Each release that is associated with an operating system will look similar to the following structure.

Version         | ServicingOptions | AvailabilityDate       | KBArticle | KBArticleURL                              
--------------- | ---------------- | ---------------------- | --------- | ------------------------------------------
10.0.22621.963  | General Availability Channel | 12/13/2022 12:00:00 AM | KB5021255 | https://support.microsoft.com/help/5021255
10.0.15063.909  | SemiAnnual Channel | 2/13/2018 12:00:00 AM  | KB4074592 | https://support.microsoft.com/help/4074592
10.0.20348.288  | LTSC             | 10/12/2021 12:00:00 AM | KB5006699 | https://support.microsoft.com/help/5006699
10.0.20348.1129 | LTSC             | 10/11/2022 12:00:00 AM | KB5018421 | https://support.microsoft.com/help/5018421
10.0.15063.1563 | SemiAnnual Channel | 1/8/2019 12:00:00 AM   | KB4480973 | https://support.microsoft.com/help/4480973
10.0.15063.726  | SemiAnnual Channel | 11/14/2017 12:00:00 AM | KB4048954 | https://support.microsoft.com/help/4048954
10.0.15063.608  | SemiAnnual Channel | 9/12/2017 12:00:00 AM  | KB4038788 | https://support.microsoft.com/help/4038788
10.0.14393.5427 | CBB              | 10/11/2022 12:00:00 AM | KB5018411 | https://support.microsoft.com/help/5018411
10.0.22621.1928 | General Availability Channel | 6/27/2023 12:00:00 AM  | KB5027303 | https://support.microsoft.com/help/5027303
10.0.15063.1596 | SemiAnnual Channel | 1/15/2019 12:00:00 AM  | KB4480959 | https://support.microsoft.com/help/4480959
10.0.14393.4827 | CBB              | 1/5/2022 12:00:00 AM   | KB5010195 | https://support.microsoft.com/help/5010195
10.0.22621.675  | General Availability Channel | 10/18/2022 12:00:00 AM | KB5019509 | https://support.microsoft.com/help/5019509
10.0.14393.7070 | CBB              | 6/11/2024 12:00:00 AM  | KB5039214 | https://support.microsoft.com/help/5039214
10.0.14393.2248 | CBB              | 5/8/2018 12:00:00 AM   | KB4103723 | https://support.microsoft.com/help/4103723
10.0.22621.3447 | General Availability Channel | 4/9/2024 12:00:00 AM   | KB5036893 | https://support.microsoft.com/help/5036893
10.0.14393.1944 | CBB              | 12/12/2017 12:00:00 AM | KB4053579 | https://support.microsoft.com/help/4053579
10.0.22621.2792 | General Availability Channel | 12/4/2023 12:00:00 AM  | KB5032288 | https://support.microsoft.com/help/5032288
10.0.14393.6351 | CBB              | 10/10/2023 12:00:00 AM | KB5031362 | https://support.microsoft.com/help/5031362
10.0.19043.1682 | SemiAnnual Channel | 4/25/2022 12:00:00 AM  | KB5011831 | https://support.microsoft.com/help/5011831
10.0.22621.1635 | General Availability Channel | 4/25/2023 12:00:00 AM  | KB5025305 | https://support.microsoft.com/help/5025305
10.0.14393.3384 | CBB              | 12/10/2019 12:00:00 AM | KB4530689 | https://support.microsoft.com/help/4530689
10.0.14393.2608 | CBB              | 11/13/2018 12:00:00 AM | KB4467691 | https://support.microsoft.com/help/4467691
10.0.14393.4946 | CBB              | 2/8/2022 12:00:00 AM   | KB5010359 | https://support.microsoft.com/help/5010359
10.0.15063.1868 | SemiAnnual Channel | 6/11/2019 12:00:00 AM  | KB4503279 | https://support.microsoft.com/help/4503279
10.0.15063.1029 | SemiAnnual Channel | 4/10/2018 12:00:00 AM  | KB4093107 | https://support.microsoft.com/help/4093107

## RELATED LINKS

[https://github.com/Grace-Solutions/WindowsReleaseHistory](https://github.com/Grace-Solutions/WindowsReleaseHistory)
