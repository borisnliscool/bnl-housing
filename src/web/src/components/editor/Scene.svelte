<script lang="ts">
	import { T } from '@threlte/core';
	import { OrbitControls, TransformControls } from '@threlte/extras';
	import { type Mesh, PerspectiveCamera, Vector3 } from 'three';
	import { editorMode, editorSpace } from '../../store/stores';
	import { fetchNui } from '../../utils/fetchNui';
	import { isEnvBrowser } from '../../utils/misc';
	import { useNuiEvent } from '../../utils/useNuiEvent';

	type VecArray = [number, number, number];

	let entity: number;
	let mesh: Mesh;
	let camera: PerspectiveCamera;
	let offset: Vector3;

	let propPosition: VecArray = [0, 0, 0];
	let propRotation: VecArray = [0, 0, 0];
	let cameraPosition = new Vector3(1, 1, 1);

	const updatePositions = (updateCamera = true) => {
		if (!mesh) return;

		const pos = new Vector3();
		mesh.getWorldPosition(pos);

		const radToDeg = 180 / Math.PI;

		const data: { prop: {}; camera?: {} } = {
			prop: {
				entity: entity,
				position: {
					x: pos.x,
					y: pos.y,
					z: pos.z
				},
				rotation: {
					yaw: mesh.rotation.y * radToDeg,
					pitch: mesh.rotation.x * radToDeg,
					roll: mesh.rotation.z * radToDeg
				}
			}
		};

		if (updateCamera && camera) {
			data.camera = {
				position: camera.position
			};
		}

		!isEnvBrowser() && fetchNui('update', data);
	};

	$: (propPosition || propRotation) && updatePositions();

	useNuiEvent<{
		entity: number;
		position: Vector3;
		rotation: { yaw: number; pitch: number; roll: number };
	}>('setup', (data) => {
		entity = data.entity;
		propPosition = [data.position.x, data.position.y, data.position.z];
		propRotation = [data.rotation.yaw, data.rotation.pitch, data.rotation.roll];
	});

	const mouseDown = () => {
		offset = new Vector3(
			camera.position.x - mesh.position.x,
			camera.position.y - mesh.position.y,
			camera.position.z - mesh.position.z
		);
	};

	const mouseUp = () => {
		propPosition = [mesh.position.x, mesh.position.y, mesh.position.z];
		propRotation = [mesh.rotation.y, mesh.rotation.x, mesh.rotation.z];
		cameraPosition = new Vector3().addVectors(offset, mesh.position);
		camera.lookAt(mesh.position);
	};
</script>

<T.PerspectiveCamera
	makeDefault
	position={[10, 10, 10]}
	fov={70}
	on:create={({ ref }) => {
		ref.lookAt(new Vector3(propPosition[0], propPosition[1], propPosition[2]));
		camera = ref;
	}}
>
	<OrbitControls target={propPosition} enablePan={false} on:change={() => updatePositions(true)} />
</T.PerspectiveCamera>

<T.Mesh
	position={propPosition}
	rotation={propRotation}
	let:ref
	on:create={({ ref }) => (mesh = ref)}
>
	<TransformControls
		object={ref}
		mode={$editorMode}
		space={$editorSpace}
		size={0.75}
		on:mouseDown={mouseDown}
		on:mouseUp={mouseUp}
		on:objectChange={(_) => updatePositions(false)}
	/>

	<!-- <T.BoxGeometry args={[1, 1, 1]} /> -->
	<!-- <T.MeshBasicMaterial color="red" /> -->
</T.Mesh>
