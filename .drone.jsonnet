local name = 'kimai';
local version = '2.40.0';
local php = '8.3.36-fpm-bookworm';
local nginx = '1.24.0';
local mariadb = '10.5.16-alpine';
local debian = 'bookworm-slim';
local platform = '26.04.10';
local playwright = 'mcr.microsoft.com/playwright:v1.59.1-jammy';
local store_publisher = 'stable-346';
local python = '3.12-slim-bookworm';
local distro_default = 'bookworm';
local distros = ['bookworm'];

local build(arch, test_ui) = [
{
  kind: 'pipeline',
  type: 'docker',
  name: arch,
  platform: {
    os: 'linux',
    arch: arch,
  },
  steps: [
           {
             name: 'php',
             image: 'php:' + php,
             commands: [
               './php/build.sh',
               './php/build-server.sh ' + version,
             ],
           },
           {
             name: 'php test',
             image: 'syncloud/platform-' + distro_default + '-' + arch + ':' + platform,
             commands: [
               './php/test.sh',
               './php/test-server.sh',
             ],
           },
           {
             name: 'nginx',
             image: 'nginx:' + nginx,
             commands: [
               './nginx/build.sh',
             ],
           },
           {
             name: 'nginx test',
             image: 'syncloud/platform-' + distro_default + '-' + arch + ':' + platform,
             commands: [
               './nginx/test.sh',
             ],
           },
           {
             name: 'mariadb',
             image: 'linuxserver/mariadb:' + mariadb,
             commands: [
               './mariadb/build.sh',
             ],
           },
           {
             name: 'mariadb test',
             image: 'syncloud/platform-' + distro_default + '-' + arch + ':' + platform,
             commands: [
               './mariadb/test.sh',
             ],
           },
           {
             name: 'cli',
             image: 'golang:1.23',
             commands: [
               './cli/build.sh',
             ],
           },
           {
             name: 'package',
             image: "debian:" + debian,
             commands: [
               './package.sh ' + name + ' $DRONE_BUILD_NUMBER',
             ],
           },
         ] + [
           {
             name: 'test ' + distro,
             image: 'python:' + python,
             commands: [
               './ci/test.sh test.py ' + distro + ' ' + name,
             ],
           }
           for distro in distros
         ] + (if test_ui then [
                {
                  name: 'e2e',
                  image: playwright,
                  commands: [
                    './test/e2e/run.sh specs/01-smoke.spec.ts',
                  ],
                },
              ] else []) +
         (if arch == 'amd64' then [
            {
              name: 'test-upgrade',
              image: 'python:' + python,
              commands: [
                './ci/test.sh upgrade.py ' + distro_default + ' ' + name,
              ],
              privileged: true,
            },
          ] else []) + [
    {
      name: 'publish',
      image: 'syncloud/store-publisher:' + store_publisher,
      environment: {
        SYNCLOUD_TOKEN: { from_secret: 'SYNCLOUD_TOKEN' },
      },
      command: ['snap', '-c', '${DRONE_BRANCH}'],
      when: {
        branch: ['stable'],
        event: ['push'],
      },
    },
    {
      name: 'artifact',
      image: 'appleboy/drone-scp:1.6.4',
      settings: {
        host: {
          from_secret: 'artifact_host',
        },
        username: 'artifact',
        key: {
          from_secret: 'artifact_key',
        },
        timeout: '2m',
        command_timeout: '2m',
        target: '/home/artifact/repo/' + name + '/${DRONE_BUILD_NUMBER}-' + arch,
        source: 'artifact/*',
        strip_components: 1,
      },
      when: {
        status: ['failure', 'success'],
        event: ['push'],
      },
    },
  ],
  trigger: {
    event: [
      'push',
    ],
  },
  services: [
    {
      name: name + '.' + distro + '.com',
      image: 'syncloud/platform-' + distro + '-' + arch + ':' + platform,
      privileged: true,
      volumes: [
        {
          name: 'dbus',
          path: '/var/run/dbus',
        },
        {
          name: 'dev',
          path: '/dev',
        },
      ],
    }
    for distro in distros
  ],
  volumes: [
    {
      name: 'dbus',
      host: {
        path: '/var/run/dbus',
      },
    },
    {
      name: 'dev',
      host: {
        path: '/dev',
      },
    },
  ],
}];

build('amd64', true) +
build('arm64', false)

