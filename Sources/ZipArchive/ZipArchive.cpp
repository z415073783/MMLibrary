//
//  ZipArchive.cpp
//  MGAILibrary
//
//  Created by zlm on 2019/7/1.
//  Copyright © 2019 zlm. All rights reserved.
//

#include "ZipArchive.h"
//#include "../../AI/utils.h"
#include <iostream>
#include <fstream>
#include <sys/time.h>
#include "minizip/zip.h"

zipFile ZipArchive::createZipFile(const char* zipPath) {
    zipFile _zipFile = zipOpen(zipPath, 0);
    if (!_zipFile) {
        return NULL;
    }
    return _zipFile;
}
double ZipArchive::get_current_time() {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        return tv.tv_sec * 1000.0 + tv.tv_usec / 1000.0;
}

/**
 添加文件进zip中

 @param zip zip
 @param filePath 文件全路径
 @param zipName 放入压缩包的文件名称
 @return
 */
bool ZipArchive::addFileToZip(zipFile zip, const char* filePath, const char* zipName) {

    if (!zip) {
        return false;
    }
    //获取时间
    double curTime = ZipArchive::get_current_time();
    double secTime =  curTime / 1000.0;
    struct tm *local;
    time_t t;
    t = secTime;
    local = localtime(&t);

    zip_fileinfo zipInfo = {0};
    zipInfo.tmz_date.tm_year = local->tm_year;
    zipInfo.tmz_date.tm_mon = local->tm_mon;
    zipInfo.tmz_date.tm_mday = local->tm_mday;
    zipInfo.tmz_date.tm_hour = local->tm_hour;
    zipInfo.tmz_date.tm_min = local->tm_min;
    zipInfo.tmz_date.tm_sec = local->tm_sec;


    int result = zipOpenNewFileInZip(zip, zipName, &zipInfo, NULL, 0, NULL, 0, NULL, Z_DEFLATED, Z_DEFAULT_COMPRESSION);

    if (result != Z_OK) {
        return false;
    }

    std::fstream f(filePath,std::ios::binary | std::ios::in);
    f.seekg(0, std::ios::end);
    long size = f.tellg();
    f.seekg(0, std::ios::beg);
    if ( size <= 0 )
    {
        return zipWriteInFileInZip(zip,NULL,0) == Z_OK ? true : false;
    }
    char* buf = new char[size];
    f.read(buf,size);
    result = zipWriteInFileInZip(zip,buf,(unsigned int)size);
    delete[] buf;

    if (result != Z_OK) {
        return false;
    }

    result = zipCloseFileInZip(zip);
    if (result != Z_OK) {
        return false;
    }

    return true;
}
bool ZipArchive::closeZip(zipFile file) {

    if (!file) {
        return false;
    }
    int result = zipClose(file, NULL);
    if (result != Z_OK) {
        return false;
    }

    return true;
}
