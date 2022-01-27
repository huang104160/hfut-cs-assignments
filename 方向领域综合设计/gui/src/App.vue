<template>
  <div id="app">
    <el-row style="width: 100%">
      <el-col :span="12" style="height: 100%">
        <div id="draw" style="height: 100%">
          <div style="display: flex; justify-content: space-between; flex-wrap: wrap;">
            <div
              style="flex-shrink: 0; flex-grow: 0"
              v-for="(value, name) in ROOM_CLASS"
              :key="name"
            >
              <div
                :style="{
                  height: '40px',
                  width: '40px',
                  margin: '10px',
                  'background-color': ID_COLOR[value],
                  cursor: 'pointer',
                }"
                @click="addNewRoom(value - 1)"
              ></div>
              <div style="text-align: center; width: 60px">{{ name }}</div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :span="12" style="height: 100%">
        <div id="result" style="height: 100%; text-align: center; display: flex; flex-direction: column; justify-content: space-between; align-items: center;">
          <el-button
            style="margin: 20px"
            type="primary"
            :loading="loading"
            :disabled="clicked !== -1"
            @click="generate()"
            >生成 / 换一个</el-button
          >
          <img style="margin-top: 120px;" :src="imgurl" alt="" />
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script>
// import HelloWorld from './components/HelloWorld.vue'

import axios from "axios";
import * as d3 from "d3";

export default {
  name: "App",
  data: function () {
    return {
      loading: false,
      clicked: -1,
      imgurl: "",
      // ID_COLOR: {
      //   1: "#EE4D4D",
      //   2: "#C67C7B",
      //   3: "#FFD274",
      //   4: "#BEBEBE",
      //   5: "#BFE3E8",
      //   6: "#7BA779",
      //   7: "#E87A90",
      //   8: "#FF8C69",
      //   10: "#1F849B",
      //   15: "#727171",
      //   16: "#785A67",
      //   17: "#D3A2C7",
      // },
      ID_COLOR: {
        1: "#1ABC9C",
        2: "#2ECC71",
        3: "#F1C40F",
        4: "#E74C3C",
        5: "#34495E",
        6: "#E67E22",
        7: "#3498DB",
        8: "#9B59B6",
        10: "#ECF0F1",
        15: "#7F8C8D",
        17: "#BDC3C7"
      },
      ROOM_CLASS: {
        "living room": 1,
        kitchen: 2,
        bedroom: 3,
        bathroom: 4,
        balcony: 5,
        entrance: 6,
        "dining room": 7,
        "study room": 8,
        storage: 10,
        "front door": 15 /*, "unknown": 16, "interior_door": 17*/,
      },
      nodes: [
        { id: 0, group: 0 },
        { id: 1, group: 2 },
        { id: 2, group: 2 },
        { id: 3, group: 3 },
        { id: 4, group: 14 },
      ],
      links: [
        { source: 0, target: 1, value: 1 },
        { source: 0, target: 2, value: 1 },
        { source: 0, target: 3, value: 1 },
        { source: 0, target: 4, value: 1 },
        { source: 1, target: 3, value: 1 },
      ],
    };
  },

  components: {},

  mounted: function () {
    this.ForceGraphWrapper();
  },

  methods: {
    addNewRoom(group) {
      if (group === 14 || group === 0) {
        this.$message.warning({
          message: "前门和客厅不允许修改",
          duration: 1000,
        });
        return;
      }

      this.nodes.push({
        id: this.nodes[this.nodes.length - 1].id + 1,
        group: group,
      });
      document.getElementsByTagName("svg")[0].remove();
      this.ForceGraphWrapper();
    },

    onClick(id) {
      const node = this.nodes.find((node) => node.id === id);
      if (node.group === 14) {
        this.$message.warning({
          message: "前门和客厅不允许修改",
          duration: 1000,
        });
        this.clicked = -1;
        return;
      }

      if (this.clicked == -1) {
        this.$message({ message: "请再点击另一个节点", duration: 1000 });
        this.clicked = id;
        return;
      }

      if (id === this.clicked) {
        // 两次都是点同一个节点，等于删除节点

        if (node.group === 0) {
          this.$message.warning({
            message: "前门和客厅不允许修改",
            duration: 1000,
          });
        } else {
          this.deleteNode(id);
          this.reIndex();
          document.getElementsByTagName("svg")[0].remove();
          this.ForceGraphWrapper();
        }
      } else {
        // 两次点击不同的节点，等于删除或加上这两个节点间的边

        for (let i = 0; i < this.links.length; ++i) {
          if (
            (this.links[i].source === id &&
              this.links[i].target === this.clicked) ||
            (this.links[i].source === this.clicked &&
              this.links[i].target === id)
          ) {
            this.links.splice(i, 1);
            document.getElementsByTagName("svg")[0].remove();
            this.ForceGraphWrapper();
            this.clicked = -1;
            return;
          }
        }

        if (id < this.clicked)
          this.links.push({ source: id, target: this.clicked, value: 1 });
        else this.links.push({ source: this.clicked, target: id, value: 1 });
        document.getElementsByTagName("svg")[0].remove();
        this.ForceGraphWrapper();
      }

      this.clicked = -1;
    },

    deleteNode(id) {
      // const node = this.nodes.find((node) => node.id === id);
      // if (node.group === 14 || node.group === 1) {
      //   this.$message.warning({ message: "房门不允许修改", duration: 1000 });
      //   return;
      // }

      this.nodes.splice(
        this.nodes.findIndex((node) => node.id === id),
        1
      );

      const links = [];
      for (const link of this.links) {
        if (link.source !== id && link.target !== id) links.push(link);
      }
      this.links = links;
    },

    reIndex() {
      let i = 0;
      for (const node of this.nodes) {
        if (node.id !== i) {
          for (const link of this.links) {
            if (link.source === node.id) link.source = i;
            else if (link.target === node.id) link.target = i;
          }
          node.id = i;
        }
        ++i;
      }
    },

    generate() {
      this.loading = true;

      const nodes = [];
      const edges = [];
      const frontDoorIndex = this.nodes.findIndex((node) => node.group === 14);
      const numInteriorDoor = this.links.length - 1;

      for (const node of this.nodes) nodes.push(node.group);
      for (let i = 0; i < numInteriorDoor; ++i) nodes.push(16);

      for (let i = 0; i < nodes.length; ++i) {
        for (let j = i + 1; j < nodes.length; ++j) {
          edges.push([i, -1, j]);
        }
      }

      // map 保存 link 对应的 Interior Door 的下标
      const map = new Map();
      let i = this.nodes.length;
      for (const link of this.links) {
        if (link.source === frontDoorIndex || link.target === frontDoorIndex)
          continue;
        map.set(link, i);
        ++i;
      }
      for (const link of this.links) {
        const edge = edges.find(
          edge => edge[0] === link.source && edge[2] === link.target
        );
        edge[1] = 1;
        if (
          link.source !== frontDoorIndex &&
          link.target !== frontDoorIndex
        ) {
          const interiorDoorIndex = map.get(link);
          const edge1 = edges.find(
            edge => edge[0] === link.source && edge[2] === interiorDoorIndex
          );
          edge1[1] = 1;
          const edge2 = edges.find(
            edge => edge[0] === link.target && edge[2] === interiorDoorIndex
          );
          edge2[1] = 1;
        }
      }

      console.log(nodes);
      console.log(edges);

      axios({
        url: "/api/generate",
        method: "post",
        data: {
          nodes,
          edges,
        },
        responseType: "blob",
      })
        .then((res) => {
          this.imgurl = window.URL.createObjectURL(
            new window.Blob([res.data], { type: "image/png" })
          );
        })
        .finally(() => {
          this.loading = false;
        });
    },

    ForceGraphWrapper() {
      return this.ForceGraph(
        "#draw",
        {
          nodes: this.nodes,
          links: this.links,
        },
        {
          nodeId: (d) => d.id,
          nodeGroup: (d) => d.group,
          nodeTitle: (d) => `${d.id}\n${d.group}`,
          linkStrokeWidth: (l) => Math.sqrt(l.value),
          width: 720,
          height: 600,
          nodeRadius: 14,
          distance: 100,
          // invalidation // a promise to stop the simulation when the cell is re-run
        }
      );
    },

    // Copyright 2021 Observable, Inc.
    // Released under the ISC license.
    // https://observablehq.com/@d3/force-directed-graph
    ForceGraph(
      elem,
      {
        nodes, // an iterable of node objects (typically [{id}, …])
        links, // an iterable of link objects (typically [{source, target}, …])
      },
      {
        distance = 50,
        nodeId = (d) => d.id, // given d in nodes, returns a unique identifier (string)
        nodeGroup, // given d in nodes, returns an (ordinal) value for color
        nodeGroups, // an array of ordinal values representing the node groups
        nodeTitle, // given d in nodes, a title string
        nodeFill = "currentColor", // node stroke fill (if not using a group color encoding)
        nodeStroke = "#fff", // node stroke color
        nodeStrokeWidth = 1.5, // node stroke width, in pixels
        nodeStrokeOpacity = 1, // node stroke opacity
        nodeRadius = 5, // node radius, in pixels
        nodeStrength,
        linkSource = ({ source }) => source, // given d in links, returns a node identifier string
        linkTarget = ({ target }) => target, // given d in links, returns a node identifier string
        linkStroke = "#999", // link stroke color
        linkStrokeOpacity = 0.6, // link stroke opacity
        linkStrokeWidth = 1.5, // given d in links, returns a stroke width in pixels
        linkStrokeLinecap = "round", // link stroke linecap
        linkStrength,
        colors = d3.schemeTableau10, // an array of color strings, for the node groups
        width = 640, // outer width, in pixels
        height = 400, // outer height, in pixels
        invalidation, // when this promise resolves, stop the simulation
      } = {}
    ) {
      // Compute values.
      const N = d3.map(nodes, nodeId).map(intern);
      const LS = d3.map(links, linkSource).map(intern);
      const LT = d3.map(links, linkTarget).map(intern);
      if (nodeTitle === undefined) nodeTitle = (_, i) => N[i];
      const T = nodeTitle == null ? null : d3.map(nodes, nodeTitle);
      const G = nodeGroup == null ? null : d3.map(nodes, nodeGroup).map(intern);
      const W =
        typeof linkStrokeWidth !== "function"
          ? null
          : d3.map(links, linkStrokeWidth);

      // Replace the input nodes and links with mutable objects for the simulation.
      nodes = d3.map(nodes, (_, i) => ({ id: N[i] }));
      links = d3.map(links, (_, i) => ({ source: LS[i], target: LT[i] }));

      // Compute default domains.
      if (G && nodeGroups === undefined) nodeGroups = d3.sort(G);

      // Construct the scales.
      const color =
        nodeGroup == null ? null : d3.scaleOrdinal(nodeGroups, colors);

      // Construct the forces.
      const forceNode = d3.forceManyBody();
      const forceLink = d3
        .forceLink(links)
        .id(({ index: i }) => N[i])
        .distance(distance);
      if (nodeStrength !== undefined) forceNode.strength(nodeStrength);
      if (linkStrength !== undefined) forceLink.strength(linkStrength);

      const simulation = d3
        .forceSimulation(nodes)
        .force("link", forceLink)
        .force("charge", forceNode)
        .force("center", d3.forceCenter())
        .on("tick", ticked);

      const svg =
        // d3.create("svg")
        d3
          .select(elem)
          .append("svg")
          .attr("width", width)
          .attr("height", height)
          .attr("viewBox", [-width / 2, -height / 2, width, height])
          .attr("style", "max-width: 100%; height: auto; height: intrinsic;");

      const link = svg
        .append("g")
        .attr("stroke", linkStroke)
        .attr("stroke-opacity", linkStrokeOpacity)
        .attr(
          "stroke-width",
          typeof linkStrokeWidth !== "function" ? linkStrokeWidth : null
        )
        .attr("stroke-linecap", linkStrokeLinecap)
        .selectAll("line")
        .data(links)
        .join("line");

      const node = svg
        .append("g")
        .attr("fill", nodeFill)
        .attr("stroke", nodeStroke)
        .attr("stroke-opacity", nodeStrokeOpacity)
        .attr("stroke-width", nodeStrokeWidth)
        .selectAll("circle")
        .data(nodes)
        .join("circle")
        .attr("r", nodeRadius)
        .call(drag(simulation));

      if (W) link.attr("stroke-width", ({ index: i }) => W[i]);
      // if (G) node.attr("fill", ({index: i}) => color(G[i]));
      if (G) node.attr("fill", ({ index: i }) => this.ID_COLOR[G[i] + 1]);
      if (G) node.on("click", (_, { id: i }) => this.onClick(i));
      if (T) node.append("title").text(({ index: i }) => T[i]);
      if (invalidation != null) invalidation.then(() => simulation.stop());

      function intern(value) {
        return value !== null && typeof value === "object"
          ? value.valueOf()
          : value;
      }

      function ticked() {
        link
          .attr("x1", (d) => d.source.x)
          .attr("y1", (d) => d.source.y)
          .attr("x2", (d) => d.target.x)
          .attr("y2", (d) => d.target.y);

        node.attr("cx", (d) => d.x).attr("cy", (d) => d.y);
      }

      function drag(simulation) {
        function dragstarted(event) {
          if (!event.active) simulation.alphaTarget(0.3).restart();
          event.subject.fx = event.subject.x;
          event.subject.fy = event.subject.y;
        }

        function dragged(event) {
          event.subject.fx = event.x;
          event.subject.fy = event.y;
        }

        function dragended(event) {
          if (!event.active) simulation.alphaTarget(0);
          event.subject.fx = null;
          event.subject.fy = null;
        }

        return d3
          .drag()
          .on("start", dragstarted)
          .on("drag", dragged)
          .on("end", dragended);
      }

      console.log(nodes);
      console.log(links);
    },
  },
};
</script>

<style>
</style>
