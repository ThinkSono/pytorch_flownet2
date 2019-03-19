from setuptools import setup
from setuptools.command.install import install
from setuptools.command.develop import develop
from setuptools.command.egg_info import egg_info
import subprocess


short_description = """
FlowNet implementation for thinksono.
""".strip()


def run_install():
    subprocess.call('./install.sh', shell=True)


class install_command(install):
    def run(self):
        super().run()
        run_install()


class develop_command(develop):
    def run(self):
        super().run()
        run_install()


class egg_command(egg_info):
    def run(self):
        super().run()
        run_install()


dependencies = []
test_dependencies = []
scripts = []

setup(
    name='pytorch_flownet2',
    version='0.1.0',

    description=short_description,

    url='https://github.com/thinksono/pytorch_flownet2',

    author='Antonis Makropoulos',

    author_email='antonios@thinksono.com',

    license='Private License',

    packages=['FlowNet2_src'],

    install_requires=dependencies,
    tests_require=test_dependencies,

    scripts=scripts,
    cmdclass={
        'install': install_command,
        'develop': develop_command,
        'egg_info': egg_command
    }
)
