<template>
  <div>
    <b-sidebar id="download-queue" title="Download Queue" bg-variant="dark" text-variant="light" width="30vw" right shadow>
      <b-table striped borderless outlined small dark hover v-bind:items="results" :fields="fields">
        <template #cell(video_title)="cell">
          <b-link :href="cell.item.url" target="_BLANK" title="Watch Video">
            {{cell.value}}
          </b-link>
        </template>
      </b-table>
    </b-sidebar>
  </div>
</template>
<script>

export default {
  name: 'DownloadQueue',
  props: [],
  data() {
    return {
      results: [],
      polling: null,
      fields: [
        {
          key: "video_title",
          label: "Title",
          sortable: true,
          class: "text-center"
        }
      ]
    }
  },
  components: {},
  created() {
    this.fetchDownloadQueueResults();
    this.polling = setInterval(() => {
      this.fetchDownloadQueueResults();
    }, 15000);
  },
  methods: {
    fetchDownloadQueueResults() {
      // would be nice if this listed active downloads too
      fetch("http://localhost/downloads/list", {
        method: "GET"
      })
      .then(response => response.json())
      .then(data => {
        this.results = data;
      })
    }
  }
}
</script>
<style>
  a {
    color: white;
  }
  a:hover {
    color: #c0c0c0;
  }
</style>