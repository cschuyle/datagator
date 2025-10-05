#!/usr/bin/env python3

import json
import os
import re
import subprocess
import sys

def basename(filename):
    return subprocess.run(['basename', filename], stdout=subprocess.PIPE).stdout.decode('utf-8').strip()


def uploadToS3(fullFilename, bucketSuffix=None):
    bucket = 'moocho-test'
    bucketPrefix = 'public/little-prince-ebooks'

    cleanedFilename = re.sub(r'[\s,_-]+', '-', str(basename(fullFilename)))

    if bucketSuffix:
        bucketKey = f'{bucketPrefix}/{bucketSuffix}/{cleanedFilename}'
    else:
        bucketKey = f'{bucketPrefix}/{cleanedFilename}'


    subprocess.run(['aws', 's3', 'cp', fullFilename, f's3://{bucket}/{bucketKey}'], check=True)

    try:
        subprocess.run([
            'aws', 's3api', 'put-object-acl',
            '--bucket', bucket,
            '--key', bucketKey,
            '--grant-full-control', 'emailaddress=carl@dragnon.com',
            '--grant-read', 'uri=http://acs.amazonaws.com/groups/global/AllUsers'
        ], check=True)
    except:
        print(f"@@@@ WARNING: Failed to set ACL on s3://{bucket}/{bucketKey}", file=sys.stderr)

    return f'https://{bucket}.s3-us-west-2.amazonaws.com/{bucketKey}'


def imageFileType(filename):
    filename = filename.lower()
    if filename.endswith('.jpeg'):
        return 'jpeg'
    if filename.endswith('.jpg'):
        return 'jpeg'
    if filename.endswith('.png'):
        return 'png'
    if filename.endswith('.gif'):
        return 'gif'
    if filename.endswith('.webp'):
        return 'webp'


def isCoverImage(filename):
    return filename.__contains__('cover') and imageFileType(filename) is not None


def displayableFileType(filename):
    filename = filename.lower()
    if imageFileType(filename) is not None:
        return imageFileType(filename)

    if filename.endswith('.txt'):
        return 'txt'
    if filename.endswith('.pdf'):
        return 'pdf'
    if filename.endswith('.rtf'):
        return 'rtf'
    if filename.endswith('.doc'):
        return 'doc'
    if filename.endswith('.docx'):
        return 'docx'
    if filename.endswith('.mp3'):
        return 'mp3'
    if filename.endswith('.mp4'):
        return 'mp4'
    if filename.endswith('.m4v'):
        return 'm4v'
    if filename.endswith('.zip'):
        return 'zip'
    if filename.endswith('.ibooks'):
        return 'ibooks'
    if filename.endswith('.mobi'):
        return 'mobi'
    if filename.endswith('.epub'):
        return 'epub'


def createThumbnail(dirname, filename, destDirname):
    subprocess.run(['mkdir', '-p', destDirname], check=True)
    thumbnailFilename = f'{destDirname}/{filename}'
    if False:
        subprocess.run(['magick', 'convert', f'{dirname}/{filename}', '-thumbnail', '200x200', thumbnailFilename],
                       check=True)
    else:
        subprocess.run(['convert', f'{dirname}/{filename}', '-thumbnail', '200x200', thumbnailFilename],
                       check=True)

    return thumbnailFilename


def detectLanguage(filename):
    languageSearch = re.search(r'\sin\s+([^\s)]+)', filename, re.IGNORECASE)

    if languageSearch:
        return languageSearch.group(1)


def checkAwsAuthenticated():
    try:
        subprocess.run(['aws', 's3', 'ls', '/'], check=True)
    except:
        print(
            "'aws s3 ls /' failed. Are you logged into AWS (alternatively, did you set the AWS_* environment variables?", file=sys.stderr)
        exit(1)


def checkInstalled(command):
    try:
        subprocess.run(['which', command], check=True)
    except:
        print(f"Command '{command}' failed. Installation required to continue.", file=sys.stderr)

print("ARGV: ", sys.argv, file=sys.stderr)


if len(sys.argv) == 1 or sys.argv[1].startswith('-'):
    print("""Usage: pdfs DIRECTORY ...
    
      Uploads all eligible files in each DIRECTORY (non-recursive),
      where directory name is the title of the item being uploaded,
      and can have \'in LANGUAGE\' in the name (if not, defaults to English)
      where eligible files are:
      -  Image and audio files (.jpeg, .png, .mp3, .m4v ...)
      -  Image files with the string \'cover\' in them will be uploaded in original and thumbnail-ified sizes
      -  .txt and .pdf files
    
    The type (pdf, txt, ...) of the non-cover files will be detected.
    If there are several, the first one traversed wins.
    """)
    exit(1)

checkInstalled('aws')

if False:
    checkInstalled('magick')
checkInstalled('convert')

checkAwsAuthenticated()

directories = sys.argv
directories.pop(0)

dirEntries = []

for rootDir in directories:

    for dirname, subdirList, fileList in os.walk(rootDir):

        # This is how I'm doing max-depth = 1
        if dirname.count(os.sep) - rootDir.count(os.sep) == 1:
            del subdirList[:]

        simpleDirname = basename(dirname)

        language = 'English'
        detectedLanguage = detectLanguage(simpleDirname)
        if detectedLanguage:
            language = detectedLanguage

        largeImageUrl = None
        smallImageUrl = None
        fileUrls = []

        fileType = None
        for filename in fileList:
            thisFileType = displayableFileType(filename)
            if thisFileType is None:
                print(f'Ignoring non-displayable file {filename}', file=sys.stderr)
                continue

            uploadedUrl = uploadToS3(f'{dirname}/{filename}')
            if isCoverImage(filename):
                largeImageUrl = uploadedUrl
                smallImageFilename = createThumbnail(dirname, filename, f'{dirname}/150')
                smallImageUrl = uploadToS3(smallImageFilename, '150')
            else:
                fileUrls.append(uploadedUrl)
                fileType = fileType or thisFileType

        if len(fileUrls) > 0:
            dirEntries.append({
                'littlePrinceItem': {
                    'title': simpleDirname,
                    'largeImageUrl': largeImageUrl,
                    'smallImageUrl': smallImageUrl,
                    'files': fileUrls,
                    'language': language,
                    'format': fileType or 'unknown'
                }
            })

print(json.dumps(dirEntries, indent=2))
