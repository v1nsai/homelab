pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-kaniko
spec:
  serviceAccountName: jenkins
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command: ["/busybox/cat"]
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker/
  - name: kubectl
    image: bitnami/kubectl:1.29
    command: ["/bin/sh", "-c", "sleep 99d"]
    tty: true
  volumes:
  - name: docker-config
    secret:
      secretName: harbor-docker-config
"""
    }
  }

  options {
    timestamps()
    ansiColor('xterm')
  }

  environment {
    REGISTRY   = "harbor.internal"
    PROJECT    = "library"
    IMAGE_NAME = "pulse_api"
    NAMESPACE  = "pulse"
    // If your Harbor uses a self-signed cert, keep these; otherwise drop them.
    KANIKO_TLS = "--insecure --skip-tls-verify"
    BRANCH_NAME = "master"
  }

  triggers {
    // For Multibranch you'll typically rely on webhooks; keep empty poll to disable cron.
    pollSCM('')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Image') {
      environment {
        SHORT_SHA = "${env.GIT_COMMIT.take(7)}"
        TAG       = "${env.BRANCH_NAME}-${SHORT_SHA}"
      }
      steps {
        container('kaniko') {
          sh """
            /kaniko/executor \
              --context ${WORKSPACE} \
              --dockerfile ${WORKSPACE}/Dockerfile \
              --destination ${REGISTRY}/${PROJECT}/${IMAGE_NAME}:${TAG} \
              --destination ${REGISTRY}/${PROJECT}/${IMAGE_NAME}:latest-${BRANCH_NAME} \
              ${KANIKO_TLS}
          """
        }
      }
    }

    stage('Deploy to K8s') {
      environment {
        SHORT_SHA = "${env.GIT_COMMIT.take(7)}"
        TAG       = "${env.BRANCH_NAME}-${SHORT_SHA}"
        FULL_IMG  = "${REGISTRY}/${PROJECT}/${IMAGE_NAME}:${TAG}"
        DEPLOY    = "${IMAGE_NAME}" // assumes Deployment name == image/app name
      }
      steps {
        container('kubectl') {
          sh """
            set -euo pipefail
            # Update the workload's image to the newly built tag
            kubectl -n ${NAMESPACE} set image deploy/${DEPLOY} ${IMAGE_NAME}=${FULL_IMG} --record || true
            kubectl -n ${NAMESPACE} rollout status deploy/${DEPLOY} --timeout=5m
            # Optional: show the image now running
            kubectl -n ${NAMESPACE} get deploy ${DEPLOY} -o wide
          """
        }
      }
    }
  }

  post {
    failure {
      echo "Build failed on ${env.BRANCH_NAME}@${env.GIT_COMMIT}"
    }
  }
}