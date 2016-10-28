env.DIST = 'xenial'
env.TYPE = 'user'

cleanNode {
  stage 'generate'
  git 'https://github.com/apachelogger/kf5-snap-app'
  sh 'echo $APPNAME > appname'
  sh 'ls -lah'
  sh '~/tooling/kci/contain.rb rake generate'
  sh "echo '----snapcraft----'; cat snapcraft.yaml; echo '----snapcraft----'"
  stash includes: 'snapcraft.yaml, Rakefile', name: 'snapcraft'
}

cleanNode {
  stage 'snapcraft'
  unstash 'snapcraft'
  sh '~/tooling/kci/contain.rb rake snapcraft'
  archiveArtifacts '*_amd64.snap'
}

def cleanNode(label = null, body) {
  node(label) {
    deleteDir()
    try {
      body()
    } finally {
      step([$class: 'WsCleanup', cleanWhenFailure: true])
    }
  }
}
