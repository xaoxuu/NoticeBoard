#!/bin/bash --login


#Verify variable is provided
if [ "$1" = "" ]; then
        echo -e "Version number not provide"
        exit 1
fi

FILENAME="NoticeBoard.podspec"
VERSION=$1

sed -i "" "s/\([0-9]\)\.\([0-9]\)\.\([0-9]\)/${VERSION}/g" ${FILENAME}
git add --all
git commit -am "${VERSION}" 
git push origin
git tag ${VERSION}
git push --tags
pod lib lint


echo "please input this command to push trunk:"
echo ""
echo "pod trunk push ${FILENAME}"
echo ""

# pod trunk push ${FILENAME}
# pod trunk push NoticeBoard.podspec