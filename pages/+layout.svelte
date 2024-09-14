<script>
  import '@evidence-dev/tailwind/fonts.css';
  import '../app.css'; 
  import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
  export let data;
</script>

<EvidenceDefaultLayout {data} githubRepo="https://github.com/gallochris/evdev-byc" logo="https://substackcdn.com/image/fetch/w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F5135d278-3236-4414-9b46-b386297e29cb_566x90.png">
  <slot slot="content" />
</EvidenceDefaultLayout>