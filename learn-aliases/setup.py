from setuptools import setup, find_packages

setup(
    name="learn-aliases",
    version="1.0.0",
    description="Interactive quiz to learn mac-dev-setup aliases",
    author="mac-dev-setup",
    packages=find_packages(),
    entry_points={
        "console_scripts": [
            "learn-aliases=learn_aliases.cli:main",
        ],
    },
    python_requires=">=3.8",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
)