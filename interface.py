from neo4j import GraphDatabase as gds
#from neo4j.graph_algo import pagerank

class Interface:
    def __init__(self, uri, user, password):
        self._driver = gds.driver(uri, auth=(user, password), encrypted=False)
        self._driver.verify_connectivity()
        self.result=[]
        self.bfs_result=[]


    def close(self):
        self._driver.close()

    def bfs(self, start_node, last_node):
        # TODO: Implement this method
        session = self._driver.session()


        graph=session.run("CALL gds.graph.project('BFS_bf', 'Location', 'TRIP')")
        result_bfs=session.run("MATCH (source:Location{name:$src}),(target:Location{name:$target})"
        "CALL gds.bfs.stream('BFS_bf', {sourceNode: source,targetNodes: [target]}) YIELD path RETURN path",src=start_node,target=last_node)
        dict_bfs=result_bfs.data()[0]
        self.bfs_result.append(dict_bfs)
        return self.bfs_result
        #raise NotImplementedError

    def pagerank(self, max_iterations, weight_property):

        session = self._driver.session()
        # TODO: Implement this method

        graph=session.run("CALL gds.graph.project('PageRank_pr','Location','TRIP',{relationshipProperties: $weight})",weight=weight_property)
        page_rank = session.run("CALL gds.pageRank.stream('PageRank_pr',"
                     "{maxIterations: $maxIter, dampingFactor: 0.85, relationshipWeightProperty:$weight}) "
                      "YIELD nodeId, score "
                     "MATCH (node) WHERE id(node) = nodeId "
                     "RETURN node.name as name , score as score "
                     "ORDER BY score DESC",weight=weight_property,maxIter= max_iterations)
        # Print the nodes with the highest and lowest PageRank
        maxscore = 0
        for each in page_rank:
            if each['score']>maxscore:
                self.result.append({'name':each['name'],'score':each['score']})
                maxscore=each['score']
        self.result.append({'name':each['name'],'score':each['score']})
        session.close()
        return self.result

        session.close()
        raise NotImplementedError
