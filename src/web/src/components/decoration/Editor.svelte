<script lang="ts">
	import * as Threlte from "@threlte/core";
	import { useNuiEvent } from "../../utils/useNuiEvent";
	import * as Three from "three";
	import * as Utils from "three/src/math/MathUtils";
	import { editorMode } from "../../store/stores";
	import { fetchNui } from "../../utils/fetchNui";
	import { isEnvBrowser, type modeType } from "../../utils/misc";

	let entity: number;
	let propPosition = new Three.Vector3(0, 0, 0);
	let propRotation = new Three.Euler(Utils.DEG2RAD * 90, 0, 0);

	let offset: Three.Vector3;
	let cameraPosition = new Three.Vector3(
		propPosition.x + 1,
		propPosition.y + 1,
		propPosition.z + 1
	);
	let mode: modeType = "translate";
	let camera: Three.PerspectiveCamera;
	let mesh: any;

	const updatePositions = () => {
		const data = {
			prop: {
				entity: entity,
				position: propPosition,
				rotation: {
					x: Utils.radToDeg(propRotation.x),
					y: Utils.radToDeg(propRotation.y),
					z: Utils.radToDeg(propRotation.z),
				},
			},
			camera: {},
		};

		if (camera) {
			data.camera = {
				position: camera.position,
			};
		}

		try {
			!isEnvBrowser() && fetchNui("update", data);
		} catch (err) {}
	};

	$: (propPosition || propRotation) && updatePositions();

	useNuiEvent<any>("setup", (data) => {
		entity = data.entity;
		propPosition = data.position;
		propRotation = data.rotation;
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
		<Threlte.OrbitControls target={propPosition} on:change={updatePositions} />
	</Threlte.PerspectiveCamera>

	<Threlte.AmbientLight intensity={0.5} />

	<Threlte.Mesh
		bind:mesh
		geometry={new Three.PlaneGeometry(0, 0)}
		material={new Three.MeshStandardMaterial({
			color: "white",
			side: Three.DoubleSide,
		})}
		position={propPosition}
		rotation={propRotation}
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
