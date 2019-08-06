# Ethos
A collection of private cocoapods built in-house. This is where we package and distribute common ios functionality.

## Creating a new cocoapod

1. Select a `<pod_name>` that functionally describes what the pod does
	
	- follow the existing Camelcase convention
	- be sure to namespace your pod with the Albatross prefix

2. Create `<pod_name>.podspec`. My suggestion is to

	- Clone one of the existing `.podspec` files.
	- Set the following parameters:
		- `spec.name` to `<pod_name>`
		- `spec.summary`
		- `spec.description`
		- `spec.version` to "0.1.0"

3. Create a Xcode Project

	- File -> New -> Project...
	- From the "Framework & Library" menu, select Framework
	- Set the following parameters:
		- Product Name to `<pod_name>`
		- Team to `None`
		- Organization Name to `Lumi Labs`
		- Organization Identifier to `com.lumilabs`
		- Language to `Swift`
		- Check "Include Unit Tests"
	- Select the albatross root directory and hit the "Create" button

4. Register your new pod in the albatross-specs repository

	```
	pod repo add <pod_name>Spec https://github.com/lumilabs/ethos-specs
	```

	eg. `pod repo add EthosUtilSpec https://github.com/lumilabs/ethos-specs`

:smiley::clap:

## Release new cocoapod version

1. Lint your `.podspec` file and fix any reported problems

2. Run `.tools/release_pod.py` from the albatross root directory

	```
	# specific pod 
	python .tools/release_pod.py --pods <pod_name_1> <pod_name_2>
	eg. python .tools/release_pod.py --pods networking
	eg. python .tools/release_pod.py --pods networking util
	```

	```
	# all pods
	python .tools/release_pod.py
	```


## Pod Lint FAQs

**Add problems and solutions here as you discover them**




## Appendix

