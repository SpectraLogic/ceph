final FAILURE = '#FF0000'

def keepgoing = true
def buildTest = JOB_NAME.contains("BuildTest")
def signTest = params.PRODUCTION

def getPreviousStatus(build) {
    if (build == null) {
        return 'ABORTED'
    }
    if (build.result != null && build.result != 'ABORTED') {
        return build.result
    }
    return getPreviousStatus(build.getPreviousBuild())
}

def notifyStatusChange(buildStatus) {
    final UNKNOWN  = '#0000FF'
    final SUCCESS  = '#00FF00'
    final UNSTABLE = '#FFFF00'

    def color = UNKNOWN

    switch (buildStatus) {
        case 'SUCCESS':
            color = SUCCESS
            break

        case 'UNSTABLE':
            color = UNSTABLE
            break
    }

    // Notification already happened if 'FAILURE'. We don't care about canceled builds
    def prevStatus = getPreviousStatus(currentBuild.getPreviousBuild())
    if (buildStatus != prevStatus && buildStatus != 'FAILURE' && buildStatus != 'ABORTED' && prevStatus != 'ABORTED') {
        echo "Status notifcation (previous, current): ${prevStatus}, ${buildStatus}"
        sendNotification(color, buildStatus)
    }
}

def sendNotification(color, buildStatus) {
    slackSend(color: color, message: buildStatus + ": ${env.JOB_NAME} [${env.BUILD_NUMBER}] (<${env.BUILD_URL}|open>)")
}

pipeline {
    agent { label "LINUX" }

    // START_JENKINSFILE_PIPELINE_SPECIFIC
    // Note: see bin/jf_to_jbt
    //
    options {
        buildDiscarder(logRotator(daysToKeepStr: '30', artifactNumToKeepStr: '2'))
        disableConcurrentBuilds()
    }
    // END_JENKINSFILE_PIPELINE_SPECIFIC

    parameters {
        string(defaultValue: '/scratch/packages/vail/ceph', description: 'Path to archive packages, branch added ' +
                'automatically', name: 'BUILD_PKG_ROOT')
    }
    environment {
	// VAIL_* variables define the Vail package to 
	// include in the VailOS image.
	//
	CEPH_BRANCH = master

	WORK_DIR = "/tmp/ceph_work/${env.BRANCH_NAME}_branch"

    }
    stages {
        stage('CheckCause') {
            when {
                expression {
                    buildTest &&
                    "${currentBuild.getBuildCauses('jenkins.branch.BranchEventCause').size()}" != "0"
                }
            }
            steps {
                script {
                    currentBuild.result = 'ABORTED'
                    keepgoing = false
                    echo "Skipping build caused by: ${currentBuild.getBuildCauses()[0].shortDescription}"
                }
            }
        }
        stage('Clean') {
            when { expression { keepgoing } }
            steps {
                sh "sudo rm -fr ${env.WORK_DIR}/*"
                sh "sudo git clean -xdf"
            }
        }
        stage('Build Ceph') {
            when { expression { keepgoing } }
            steps {
                sh "TMPDIR='${env.WORK_DIR}' ./make-debs.sh"
            }
        }
        stage('Archive') {
            when { expression { keepgoing && !buildTest } }
            steps {
                sh "cp ${env.WORK_DIR}/release/pool/main/c/ceph/*.deb ${params.BUILD_PKG_ROOT}/${env.BRANCH_NAME}"
                }
            }
        }
    }
    post {
        success {
            notifyStatusChange(currentBuild.currentResult)
        }
        failure {
            sendNotification(FAILURE, currentBuild.currentResult)
        }
	cleanup {
	}
    }
}
