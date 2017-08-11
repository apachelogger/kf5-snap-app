env.DIST = 'xenial'
env.TYPE = 'user'
env.DOCKER_ENV_WHITELIST = 'APPNAME'

cleanNode('amd64') {
  stage 'generate'
  git 'https://github.com/apachelogger/kf5-snap-app'
  sh 'echo $APPNAME > appname'
  sh 'ls -lah'
  sh '~/tooling/nci/contain.rb rake generate'
  sh "echo '----snapcraft----'; cat snapcraft.yaml; echo '----snapcraft----'"
  archiveArtifacts 'snapcraft.yaml, setup/**'
  stash includes: '**', name: 'snapcraft'
}

cleanNode('amd64 && cloud') {
  stage 'snapcraft'
  unstash 'snapcraft'
  sh 'tree || ls -lahR'
  sh '~/tooling/nci/contain.rb rake snapcraft'
  archiveArtifacts '*_amd64.snap'
  stash name: 'snaps', includes: 'Rakefile, *_amd64.snap'
}

cleanNode('master') {
  stage 'snapcraft push'
  unstash 'snaps'
  sh 'env'
  sh 'echo $APPNAME > appname'
  sh 'tree || ls -lahR'
  // Temporary workspace during pipeline execution can't be accessed via UI, so
  // this should be save.
  // Even so we should move to a contain.rb which forward mounts the snapcraft
  // dir as volume into the container.
  sh 'cp ~/.config/snapcraft/snapcraft.cfg snapcraft.cfg'
  sh '~/tooling/nci/contain.rb rake publish'
}

def cleanNode(label = null, body) {
  node(label) {
    deleteDir()
    try {
      wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
        wrap([$class: 'TimestamperBuildWrapper']) {
          body()
        }
      }
    } finally {
      step([$class: 'WsCleanup', cleanWhenFailure: true])
    }
  }
}
