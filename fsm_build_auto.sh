#!/usr/bin/python
# version 1.0.0
import sys, os, shutil, getopt
from xml.dom import minidom

from subprocess import call
# constants


# function implementation (greeting message)
def greeting_message():
    print 'fsm_multi_build start...'

def help_message():
    print 'Usage :'
    print '       fsm_multi_build.py -c <cfg_path> -s <src_dir> -p <pkg_store_dir>'

# function implementation ( get count of build list )
def get_count_of_build_list(xmlPath):
    xml_doc = minidom.parse(xmlPath)
    build_list = xml_doc.getElementsByTagName("build")
    return (len(build_list))


# function implementation ( get config )
def get_val_from_xml(xmlPath, buildNo):
    xml_doc = minidom.parse(xmlPath)
    build_list = xml_doc.getElementsByTagName("build")

    elem_id = build_list[buildNo-1].getElementsByTagName("id")
    elem_branch = build_list[buildNo-1].getElementsByTagName("branch")
    elem_ifqver = build_list[buildNo-1].getElementsByTagName("IFQ_VER")
    elem_pkg_type = build_list[buildNo-1].getElementsByTagName("PKG_TYPE")
    return elem_id[0].attributes['val'].value, elem_branch[0].attributes['val'].value, \
     elem_ifqver[0].attributes['val'].value, elem_pkg_type[0].attributes['val'].value



# function implementation (change rel_config)
def change_rel_config(newVerString,newPkgType):
    call(["sed -i '/^IFQ_VER=/s/=.*/="+newVerString+"/' "+ os.getcwd()+"/rel_config"], shell=True)
    call(["sed -i '/^PKG_TYPE=/s/=.*/="+newPkgType+"/' "+ os.getcwd()+"/rel_config"], shell=True)


# function implementation (remove build_dir)
def remove_directory(dirPath):
    shutil.rmtree(dirPath, ignore_errors=True)

# function implementation (git reset --hard)
def git_reset_hard():
    call(["git","reset","--hard"])

# function implementation (git co branch)
def git_checkout(branchName):
    call(["git","checkout",branchName])

# function implementation ( copy pkg file to pkg_dir )
def copy_pkg_to_storage(ifqDir,pkgDir):
    call("cp -a "+ifqDir+"/qcm/* "+pkgDir,shell=True)
    call("cp -a "+ifqDir+"/sef/* "+pkgDir,shell=True)

# function implementation ( remove build_dir )
def remove_build_dir():
    call(["rm", "-rf", os.getcwd()+"/build"])
    call(["rm", "-rf", os.getcwd()+"/metabuild"])


# function implementation ( build )
def fsm_build(branchName,ifqVer,pkgType,pkgDir):
    # 0. remove build_dir
    print 'remove build_dir'
    remove_build_dir()
    # 1. git reset
    print 'git reset'
    git_reset_hard()
    # 2. checkout branch
    print 'checkout branch to '+branchName
    git_checkout(branchName)
    # 3. change rel_config
    print "change rel_config("+ifqVer+","+pkgType+")"
    change_rel_config(ifqVer,pkgType)
    # 4. build start
    print 'build start'
    call([os.getcwd()+"/build_package", ""], shell=True)
    # 5. copy pkg to storage
    print 'copy pkg to storage('+pkgDir+')'
    copy_pkg_to_storage(os.getcwd()+"/build/ifq_package",pkgDir)



# main function implementation
#  args :
#   target directory ( e.g ~/femto/fsm )


def main(argv):
    greeting_message()
    cfg_path = ''
    src_dir = ''
    pkg_dir = ''

    try:
        opts, args = getopt.getopt(argv,"c:s:p:",["cfg_file_path=","src_dir=","pkg_dir="])
    except getopt.GetoptError:
        help_message()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            help_message()
            sys.exit()
        elif opt in ("-c", "--cfg_file_path"):
            cfg_path = os.path.abspath(arg)
        elif opt in ("-s", "--src_dir"):
            src_dir = os.path.abspath(arg)
        elif opt in ("-p", "--pkg_dir"):
            pkg_dir = os.path.abspath(arg)
        else:
            help_message()
            sys.exit(2)

    # parameter verification
    if cfg_path == '' or src_dir == '' or pkg_dir == '':
        print 'Error : parameters are not satisfied'
        sys.exit()

    print "cfg_path =%s" % cfg_path
    print "src_dir =%s" % src_dir
    print "pkg_dir =%s" % pkg_dir

    # change current directory to src_dir
    os.chdir(src_dir)
    print 'current dir = '+os.getcwd()

    # build multiple times
    build_times = get_count_of_build_list(cfg_path)
    print 'build %d times start...' % build_times
    for x in range(1,build_times):
        print 'id = %d ' % x
        curId, curBranch,curIfqVer,curPkgType = get_val_from_xml(cfg_path,x)
        print curId+curBranch+curIfqVer+curPkgType
        fsm_build(curBranch,curIfqVer,curPkgType,pkg_dir)

# run main
if __name__ == "__main__":
   main(sys.argv[1:])
