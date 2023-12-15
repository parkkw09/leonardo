package app.peter.leonardo.ui.home

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.appcompat.widget.Toolbar
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import app.peter.leonardo.R
import app.peter.leonardo.adapter.DefaultAdapter
import app.peter.leonardo.dialog.CustomDialog

class HomeFragment : Fragment() {

    private lateinit var homeViewModel: HomeViewModel
    private val data = arrayListOf("item1", "item2", "item3", "item4", "item5", "item6")

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        homeViewModel = ViewModelProvider(this)[HomeViewModel::class.java]
        val root = inflater.inflate(R.layout.fragment_home, container, false)
        val list: RecyclerView = root.findViewById(R.id.recycler)
        val fragmentToolbar: Toolbar = root.findViewById(R.id.toolbar)
        val image: ImageView = root.findViewById(R.id.image)
        homeViewModel.text.observe(viewLifecycleOwner, Observer {
            fragmentToolbar.title = it
        })

        image.setOnClickListener {
            context?.run {
                CustomDialog.Builder(this)
                    .setButtonTitle("확인")
                    .setView(ImageView(this).apply {
                        setImageResource(R.drawable.iu01)
                    })
                    .setListener {
                        Log.d("HomeFragment", "Custom Dialog")
                    }
                    .show()
            }
        }

        list.apply {
            layoutManager = LinearLayoutManager(context)
            adapter = DefaultAdapter(data)
        }
        return root
    }
}