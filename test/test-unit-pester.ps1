using module ../cmdlets/Get-BestSizeUnit.psm1

BeforeAll { 
    import-module -name ./fastfsc.psm1 -Force

}

Describe "fastfsc.Get-FolderSizeFast" {

    it "Get-FolderSizeFast | Should Return a FolderSize PsCustomObject" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-FolderSizeFast -Path $folder.FullName
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject
    }
    
}

Describe "fastfsc.Get-FolderSizeFast" {
    it "Get-FolderSizeFast -detailed | Should Return a FolderSize PsCustomObject" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-FolderSizeFast -Path $folder.FullName -Detailed
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject
    }
}

Describe "fastfsc.Get-FolderSizeParallel" {
    it "Get-FolderSizeParallel | Should Return a FolderSize PsCustomObject" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-FolderSizeParallel -Path $folder.FullName
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject
    } 
}

Describe "fastfsc.Get-BestSizeUnit" {
    it "Get-BestSizeUnit | Should Return a UnitSize String" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-BestSizeUnit -Bytes (Get-FolderSizeFast -Path $folder.FullName).SizeBytes
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType String
    }
    
}

Describe "fastfsc.Request-FolderReport" {
    it "Request-FolderReport | Should Return a FolderSize PsCustomObject" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Request-FolderReport -Path $folder.FullName
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject

        # different unit mearurement
        $result = Request-FolderReport -Path $folder.FullName -Format xml
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject

        # help
        $result = Request-FolderReport -Help
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject
    }
    
}