BeforeAll { 
    import-module -name .\fastfsc.psm1 -Force
}

Describe "cmdlets" {

    it "Get-FolderSizeFast | Should Return a FolderSize PsCustomObject" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-FolderSizeFast -Path $folder.FullName
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject
    }
    it "Get-FolderSizeFast -detailed | Should Return a FolderSize PsCustomObject" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-FolderSizeFast -Path $folder.FullName -Detailed
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject
    }
    it "Get-FolderSizeParallel | Should Return a FolderSize PsCustomObject" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-FolderSizeParallel -Path $folder.FullName
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject
    } 
    it "Get-BestSizeUnit | Should Return a UnitSize String" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-BestSizeUnit -Bytes (Get-FolderSizeFast -Path $folder.FullName).SizeBytes
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType String
    }     
}