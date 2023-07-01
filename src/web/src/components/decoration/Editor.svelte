<script lang="ts">
	import * as Threlte from "@threlte/core";
	import { useNuiEvent } from "../../utils/useNuiEvent";
	import * as Three from "three";
	import * as Utils from "three/src/math/MathUtils";
	import { editorMode } from "../../store/stores";
	import { fetchNui } from "../../utils/fetchNui";
	import { isEnvBrowser, type modeType } from "../../utils/misc";

	let propPosition = new Three.Vector3(10, 10, 10);
	let propRotation = new Three.Euler();
	let offset: Three.Vector3;
	let cameraPosition = new Three.Vector3(
		propPosition.x + 10,
		propPosition.y + 10,
		propPosition.z + 10
	);
	let mode: modeType = "translate";
	let camera: Three.PerspectiveCamera;
	let mesh: any;

	const updatePositions = () => {
		const data = {
			prop: {
				position: propPosition,
				rotation: {
					x: Utils.RAD2DEG * propRotation.x,
					y: Utils.RAD2DEG * propRotation.y,
					z: Utils.RAD2DEG * propRotation.z,
				},
			},
			camera: {},
		};

		if (camera) {
			data.camera = {
				position: cameraPosition,
				rotation: {
					x: Utils.RAD2DEG * camera.rotation.x,
					y: Utils.RAD2DEG * camera.rotation.y,
					z: Utils.RAD2DEG * camera.rotation.z,
				},
			};
		}

		!isEnvBrowser() && fetchNui("update", data);
	};

	$: (propPosition || propRotation) && updatePositions();

	useNuiEvent<Three.Vector3>("setPosition", (data) => {
		propPosition = data;
	});

	const mouseDown = () => {
		offset = new Three.Vector3(
			camera.position.x - mesh.position.x,
			camera.position.y - mesh.position.y,
			camera.position.z - mesh.position.z
		);
	};

	const mouseUp = () => {
		propPosition = mesh.position;
		propRotation = mesh.rotation;
		cameraPosition = new Three.Vector3().addVectors(offset, mesh.position);
		camera.lookAt(propPosition);
	};

	editorMode.subscribe((_mode) => {
		mode = _mode as modeType;
	});
</script>

<Threlte.Canvas>
	<Threlte.PerspectiveCamera position={cameraPosition} fov={50} bind:camera>
		<Threlte.OrbitControls target={propPosition} />
	</Threlte.PerspectiveCamera>

	<Threlte.AmbientLight intensity={0.5} />

	<Threlte.Mesh
		bind:mesh
		geometry={new Three.PlaneGeometry(20, 20)}
		material={new Three.MeshStandardMaterial({
			color: "white",
			side: Three.DoubleSide,
		})}
		position={propPosition}
		rotation={{ x: Utils.DEG2RAD * 90 }}
	>
		<!-- Todo: use on:objectChange, currently doesn't work because of position={propPosition} -->
		<Threlte.TransformControls
			{mode}
			size={0.75}
			on:mouseDown={mouseDown}
			on:mouseUp={mouseUp}
		/>
	</Threlte.Mesh>
</Threlte.Canvas>
