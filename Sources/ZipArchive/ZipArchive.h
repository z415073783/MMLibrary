//
//  ZipArchive.h
//  MGAILibrary
//
//  Created by zlm on 2019/7/1.
//  Copyright © 2019 zlm. All rights reserved.
//

#ifndef ZipArchive_h
#define ZipArchive_h

#include <stdio.h>
#include "minizip/zip.h"

class ZipArchive {
    static double get_current_time();
public:
    static zipFile createZipFile(const char* zipPath);
    static bool addFileToZip(zipFile zip, const char* filePath, const char* zipName);
    static bool closeZip(zipFile file);
};




#endif /* ZipArchive_h */
