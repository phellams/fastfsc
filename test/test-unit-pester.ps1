using module ../cmdlets/Get-BestSizeUnit.psm1

BeforeAll { 
    import-module -name ./fastfsc.psm1 -Force

}

Describe "fastfsc.Get-FolderSizeFast" {

    it "Should Return a FolderSize PsCustomObject" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-FolderSizeFast -Path $folder.FullName
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PsCustomObject
    }
    it "-Format json | Should return json string" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-FolderSizeFast -Path $folder.FullName -Format json
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType string
    }
    
    it "-Format xml | should return xml" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Get-FolderSizeFast -Path $folder.FullName -Format xml
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType xml
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
    it "Should Return a FolderSize PsCustomObject" {
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Request-FolderReport -Path $folder.FullName
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PSCustomObject
    }

    it "Request-FolderReport | Should Return a FolderSize array" {
        # different unit mearurement
        $result = Request-FolderReport -Path  .\cmdlet, .\libs
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType PSCustomObject
    }

    it "Should Return a FolderSize string" {
        # different unit mearurement
        $folder = Get-ChildItem -Path .\ -Directory | Select-Object -First 1
        $result = Request-FolderReport -Path $folder.FullName -Format json
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType string
    }

    it "Should Return a FolderSize string" {
        # help
        $result = Request-FolderReport -Help
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType string
    }
}