<script lang="ts">
	import * as Threlte from "@threlte/core";
	import { useNuiEvent } from "../../utils/useNuiEvent";
	import * as Three from "three";
	import * as Utils from "three/src/math/MathUtils";
	import { editorMode } from "../../store/stores";

	let position = new Three.Vector3(10, 10, 10);
	let rotation = new Three.Euler();
	let offset: Three.Vector3;
	let cameraPosition = new Three.Vector3().addVectors(
		position,
		new Three.Vector3(10, 10, 10)
	);

	let camera: any;
	let mesh: any;

	const updatePositions = () => {
		const data = {
			prop: {
				position: position,
				rotation: {
					x: Utils.RAD2DEG * rotation.x,
					y: Utils.RAD2DEG * rotation.y,
					z: Utils.RAD2DEG * rotation.z,
				},
			},
		};
		console.log(data.prop);
	};

	$: (position || rotation) && updatePositions();

	useNuiEvent<Three.Vector3>("setPosition", (data) => {
		position = data;
	});

	const mouseDown = () => {
		offset = new Three.Vector3(
			camera.position.x - mesh.position.x,
			camera.position.y - mesh.position.y,
			camera.position.z - mesh.position.z
		);
	};

	const mouseUp = () => {
		position = mesh.position;
		rotation = mesh.rotation;
		cameraPosition = new Three.Vector3().addVectors(offset, mesh.position);
		camera.lookAt(position);
	};

    type modeType = "translate" | "rotate";
    let mode: modeType = "translate";
    editorMode.subscribe((_mode) => {
        mode = _mode as modeType;
    })
</script>

<Threlte.Canvas>
	<Threlte.PerspectiveCamera position={cameraPosition} fov={50} bind:camera>
		<Threlte.OrbitControls target={position} />
	</Threlte.PerspectiveCamera>

	<Threlte.AmbientLight intensity={0.5} />

	<Threlte.Mesh
		bind:mesh
		geometry={new Three.PlaneGeometry(20, 20)}
		material={new Three.MeshStandardMaterial({
			color: "white",
			side: Three.DoubleSide,
		})}
		{position}
		rotation={{ x: Utils.DEG2RAD * 90 }}
	>
		<Threlte.TransformControls
			{mode}
			size={0.75}
			on:mouseDown={mouseDown}
			on:mouseUp={mouseUp}
		/>
	</Threlte.Mesh>
</Threlte.Canvas>
